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
import type { Todo } from '@/models/Todo.model'

// on déclare une variable mesTodos qui est une ref sur un tableau de Todo


</script>

<template>
  
    <RouterView />

  <footer>
    <p>
      <RouterLink to="about">A propos de cette app</RouterLink>
      <RouterLink to="new-design">Nouveau design</RouterLink>
    </p>
  </footer>
</template>

<!--
    Inspiration du design de l'app : https://www.figma.com/community/file/879327606353067444/embed
 -->
<style scoped>

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
  text-align: center;
  font-weight: bolder;
}
</style>
