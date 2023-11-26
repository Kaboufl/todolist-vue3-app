<script setup lang="ts">
import { RouterLink } from 'vue-router';
import { computed, onMounted, ref } from 'vue';
import type { Categorie } from '@/models/Categorie.model';
import type { Todo } from '@/models/Todo.model';
import todosContainer from '@/components/todosContainer.vue';

import _ from 'lodash';

const categories = ref<Categorie[]>([]);
const todos = ref<Todo[]>([]);

const addCategoryState = ref(false);
const newCategorie = ref<Partial<Categorie>>();
newCategorie.value = {
  libelle: '',
  hex_color: '',
};

const getCategories = async () => {
  const response = await fetch('api/categories');
  const json = await response.json();

  categories.value = json.map((uneCategorie: Categorie & { id: number }) => ({
    ...uneCategorie,
    idCategorie: uneCategorie.id,
  }));
  console.log('catégories :', categories.value);
};

const handleAddCategory = async () => {
  console.log(newCategorie.value);
  try {
    const response = await fetch(`api/categories`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(newCategorie.value),
    });
    const json = await response.json();
    console.log('réponse :', json);
    newCategorie.value.idCategorie = json.id;
    categories.value.push(newCategorie.value);
    addCategoryState.value = false;
    newCategorie.value = {
      libelle: '',
      hex_color: '',
    };
    console.log(newCategorie.value, todos.value);
  } catch (error) {
    console.error(error);
  }
};

const getTodos = async () => {
  const response = await fetch('api/todos');
  const json = await response.json();

  todos.value = json.map((unTodo: Todo & { id: number; id_categorie: number }) => ({
    ...unTodo,
    category: unTodo.id_categorie,
    idTodo: unTodo.id,
  }));
};

onMounted(async () => {
  console.log('app mounted');

  await getCategories();
  await getTodos();
});

let handleUpdateTodo = _.throttle(async function (newValues: Todo) {
  console.log(newValues);
  try {
    const response = await fetch(`api/todos/${newValues.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(newValues),
    });
    const json = await response.json();
    console.log(json);
    todos.value = todos.value.map((todo: Todo) => (todo.id === newValues.id ? newValues : todo));

    console.log(todos.value);
  } catch (error) {
    console.error(error);
  }
}, 500);

const handleAddTodo = async function (newTodo: Todo) {
  console.log(newTodo);
  try {
    const response = await fetch(`api/todos`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(newTodo),
    });
    const json = await response.json();
    newTodo.id = json.id;
    console.log('réponse :', json);
    todos.value = [...todos.value, newTodo];
    console.log(newTodo, todos.value);
  } catch (error) {
    console.error(error);
  }
};

const handleDeleteTodo = async (event: number) => {
  // on fait un appel à l'API pour supprimer le todo
  console.log('delete todo:', event);

  fetch(`api/todos/${event}`, { method: 'DELETE' })
    .then((res) => res.json())
    .then((todo) => {
      // on mute la valeur de mesTodos.value, ce qui est détecté par Vue
      todos.value = todos.value.filter((t: Todo) => t.id !== event);
      console.log(todos.value, todo, event);
    });
};

const handleDeleteCategory = async (event: number) => {
  // on fait un appel à l'API pour supprimer la catégorie
  console.log('delete category:', event);

  fetch(`api/categories/${event}`, { method: 'DELETE' })
    .then((res) => res.json())
    .then((categorie) => {
      // on mute la valeur de mesTodos.value, ce qui est détecté par Vue
      categories.value = categories.value.filter((c: Categorie) => c.idCategorie !== event);
      console.log(categories.value, categorie, event);
    });
};
</script>

<template>
  <header>
    <h1 class="title">Vue 3 TodoList</h1>
    <div class="addCategoryBtn">
      <button v-if="!addCategoryState" @click="addCategoryState = !addCategoryState">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="w-6 h-6"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
        </svg>

        <span>Ajouter une catégorie</span>
      </button>
      <span v-if="addCategoryState">
        <vueticol v-model="newCategorie.hex_color" />
        <input
          type="text"
          v-model="newCategorie.libelle"
          placeholder="libellé"
          @keyup.enter="handleAddCategory"
        />
      </span>
    </div>
  </header>
  <main>
    <template v-for="categorie in categories" :key="categorie.idCategorie">
      <todosContainer
        @update:todo="($event: Todo) => handleUpdateTodo($event)"
        @newTodo="($event: Todo) => handleAddTodo($event)"
        @delete:todo="($event: number) => handleDeleteTodo($event)"
        @delete:category="($event: number) => handleDeleteCategory($event)"
        :categorie="categorie"
        :todos="todos.filter((todo: Todo) => todo.category == categorie.idCategorie)"
      />
    </template>
  </main>
  <!--
        <div class="card">
            <h2 class="title">En cours</h2>
        </div>
        <div class="card">
            <h2 class="title">Terminé</h2>
        </div>
        Si tous les todos sont done, on ajoute des confettis parce que c'est la fête 
    <img v-if="allDone" src="src/assets/confetti.svg" class="all-done" /> -->
</template>

<style scoped>
@keyframes appear {
  from {
    opacity: 0;
  }

  to {
    opacity: 1;
  }
}

header {
  height: 15vh;
  padding: 0 3rem;
  line-height: 1.5;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-family: 'Figtree', sans-serif;
}

header h1 {
  width: fit-content;
  margin: 0;
}

.title {
  text-align: left;
}

.addCategoryBtn {
  height: 3.5rem;
  width: fit-content;
  background-color: #59b4d1;
  font-family: 'Figtree', sans-serif;
  color: white;
  font-size: 0.95rem;
  border: solid 1px black;
  border-radius: 100px;
  padding: 0;
  cursor: pointer;
  outline: none;
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 0.5rem 1rem;
  gap: 1rem;
  z-index: 10;
}

.addCategoryBtn svg {
  width: 1.45rem;
  height: 1.45rem;
}
.addCategoryBtn > button {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 0.5rem;
  background-color: transparent;
  border: none;
  color: white;
  font-family: 'Figtree', sans-serif;
  white-space: nowrap;
}

.addCategoryBtn > span {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 0.5rem;
}

.addCategoryBtn > span > input {
  background-color: transparent;
  border: none;
  color: white;
  font-family: 'Figtree', sans-serif;
  white-space: nowrap;
  outline: none;
}

main {
  height: 75vh;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  justify-content: space-around;
  padding: 0 2rem;
  align-items: flex-start;
}

.card {
  width: 100%;
  border-radius: 12px;
  background-color: #0c3762;
  padding: 0.5rem;
  margin-bottom: 1rem;
}

@media screen and ((min-width: 768px)) {
  main {
    flex-direction: row;
    align-items: start;
  }
}

.new-todo {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.new-todo button {
  margin-top: 0.5rem;
}

.all-done {
  user-select: none;
  animation: appear 1s;
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  width: 100%;
  height: 100%;
  z-index: 1;
  background: rgba(250, 250, 177, 0.659);
}

.title {
  text-align: left;
  margin-left: 1rem;
  color: white;
  text-shadow: black 0.1em 0.1em 0.2em;
}

hr {
  color: goldenrod;
}
</style>
