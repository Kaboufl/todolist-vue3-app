<script setup lang="ts">
// on importe de depuis vue les fonctions qui nous intéresse (il y en a bien plus que ça)
/**
 * `ref` est la fonction qui permet de créer des références dynamiques
 * (lien vers la doc vue sur les refs : https://vuejs.org/api/reactivity-core.html#ref ).
 * Utiliser des refs permet de rendre les valeurs _réactives_,
 * c'est-à-dire de les faire réagir à des évènements et de les mettre à jour dynamiquement
 * `computed` permet de créer des valeurs calculées, c'est-à-dire une référence
 * vers une valeur qui se base sur une ou plusieurs refs
 * Doc : https://vuejs.org/api/reactivity-core.html#computed
 */
import { computed, onMounted, ref } from 'vue'
/**
 *  on importe les composants que l'on veut utiliser dans notre composant
 *  (par convention, Vue suggère que les éléments répétables soit suffixés du mot `Item`)
 *  on utilise @ pour désigner le dossier `src` (voir ./tsconfig.app.json)
 * */
import TodoItem from '@/components/TodoItem.vue'
import type { Todo } from '@/models/Todo.model'

// on déclare une variable mesTodos qui est une ref sur un tableau de Todo


const mesTodos = ref<Todo[]>([])

      onMounted(() => {
  // on utilise la fonction onMounted pour exécuter du code au moment où le composant est monté
  // on récupère les todos depuis l'api express JS (port 8080)
  console.log('App mounted')

  fetch('api/todos')
    .then((res) => res.json())
    .then((todos) => {
      // on mute la valeur de mesTodos.value, ce qui est détecté par Vue
      mesTodos.value = todos.map(({ todoId: id, ...rest}: Todo, index: number) => ({
        ...rest,
        id,
        interact: true
      }));
      console.log(mesTodos.value)
    })


})
      
      /** 
       je définis une ref computed newTodoId qui calcule le prochain id à saisir
       de cette manière je n'ai pas à me soucier de le recalculer à chaque fois 
       que j'ajoute un élément dans mon tableau mesTodos
       */
      let newTodoId = computed(() => mesTodos.value.length + 1)
      /**
       je définis une ref newTodo qui représente le Todo que l'on a ajouter
       */
      const newTodo = ref<Todo>({
        done: false,
        interact: false,
        text: '',
        id: newTodoId.value,
      })
      
      /**
       * Cette fonction permet de gérer la mise à jour d'un todo
       * @param {Todo} totoNewValue la nouvelle valeur de todo à stocker
       * fournie par le déclenchement de l'évènement `update:todo`.
       * @param index la position dans le tableau du todo à mettre à jour
       */
function handleUpdateTodo (totoNewValue: Todo, index: number) {
  /*  Vue 3 supporte l'utilisation des méthodes de mutation des array (push, slice, splice, etc...) 
      il les surcharge en ajoutant du code qui lui permet de mettre à jour la vue HTML
      on a donc le droit de les utiliser
      
      par exemple : mesTodos.value.splice(index, 1, $event);

      Ca n'est pas le cas de tous les frameworks JS, qui demandent 
      de changer la référence de la variable pour détecter les différences.
      On peut donc aussi utiliser l'object spreading sur les éléments d'un tableau pour 
      créer un nouveau tableau contenant nos éléments mis à jour
      
      fetch(``)
      mesTodos.value = [
        ...mesTodos.value.slice(0, index),
        totoNewValue,
        ...mesTodos.value.slice(index + 1),
      ]
      */

      console.log('debounced')

      fetch(`api/todos/${totoNewValue.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(totoNewValue),
      })
      .then((res) => res.json())
      .then((todo) => {
        console.log('updated Todo :', todo.id)
      })

}

const handleDeleteTodo = (id: number) => {
  // on fait un appel à l'API pour supprimer le todo

  fetch(`api/todos/${id}`, { method: 'DELETE' })
    .then((res) => res.json())
    .then((todo) => {
      // on mute la valeur de mesTodos.value, ce qui est détecté par Vue
      mesTodos.value = mesTodos.value.filter((t) => t.id !== id)
      console.log(todo)
    })
}


/**
 * fonction appelée pour ajouter le nouveau todo à la collection des todos
 */
async function handleAddTodo() {
  // si le texte n'est pas vide
  if (newTodo.value.text.length) {
    // on ajoute le todo à la liste des todos
    const res = await fetch('api/todos', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(newTodo.value),
    })
    const todo = await res.json()
  // on mute la valeur de mesTodos.value, ce qui est détecté par Vue
    mesTodos.value.push(
      /* on récupère la valeur de newTodo, et on set les propriétés displayDone et id
         (sinon on ne verrait pas la case à cocher et l'id ne serait pas à jour)
      */
      { ...todo, interact: true, id: newTodoId.value },
    )
    // alternativement, on aurait pu écrire : mesTodos.value = [...mesTodos.value, {[nouvel objet]}]

    // on reset le texte du newTodo
    newTodo.value.text = ''
  }
}
/**
 * on set une ref computed qui se met à jour dès que mesTodos est complètement done
 */
const allDone = computed(() => mesTodos.value.filter((t) => !t.done).length === 0)
</script>

<template>
  <header>
    <h1 class="title">Vue 3 TodoList</h1>
  </header>
  <main>
    <div class="card">
      <h2 class="title">Mes Todos</h2>
      <template v-for="(monTodo, index) in mesTodos" :key="monTodo.id">
        <!-- 
          on injecte la valeur de `monTodo` dans la prop `todo` 
          que l'on a défini dans `TodoItem` à l'aide de `:todo`
        -->
        <TodoItem
          :todo="monTodo"
          @update:todo="($event: Todo) => handleUpdateTodo($event, index)"
          @delete:todo="(id: number) => handleDeleteTodo(id)"
        />
        <!-- 
          on utilise `v-if` pour conditionner l'injection d'un élément selon une expression 
        -->
        <hr v-if="index !== mesTodos.length - 1" />
      </template>
    </div>
    <div class="card">
      <h2 class="title">Ajouter un Todo</h2>
      <div class="new-todo">
        <!-- 
          Ici on gère 2 évènements émis par TodoItem : 
           - `update:todo` pour récupérer la saisie du label du todo
           - `enter` pour ajouter le todo dans le tableau mesTodos à l'aide d'`addTodo`
        -->
        <TodoItem
          :todo="newTodo"
          @update:todo="($event: Todo) => (newTodo = $event)"
          @enter="handleAddTodo"
        />
        <!-- on désactive le bouton si on a rien tapé dans le todo pour éviter des saisies vides -->
        <button @click="handleAddTodo" :disabled="newTodo.text.length === 0">Ajouter</button>
      </div>
    </div>
  </main>

  <footer>
    <p>
      <RouterLink to="about">A propos de cette app</RouterLink>
    </p>
  </footer>
</template>

<!--
    Le style du composant est encapsulé (scoped), 
    c'est-à-dire que chaque règle définie ici ne s'applique que sur ce composant
    Dans les faits, Vue.js va créer un hash unique à chaque composant 
    et suffixer nos règles de style avec ce hash 
 -->
<style scoped>
header {
  line-height: 1.5;
}

.title {
  text-align: center;
}

.main {
  flex: 1 0
}

.card {
  width: calc(100% - 1rem);
  border-radius: 12px;
  background-color: rgb(242, 188, 87);
  padding: 0.5rem;
  margin-bottom: 1rem;
}

footer {
  background-color: goldenrod;
  text-align: center;
  font-weight: bolder;
}
</style>
