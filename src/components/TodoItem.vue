<script setup lang="ts">
import { LottieAnimation } from "lottie-web-vue";
import checkJSON from "@/assets/check.json";
import type { Todo } from "@/models/Todo.model";
import { defineProps, onMounted, ref } from "vue";

const anim = ref();

const props = defineProps<{ todo: Todo, index: number }>();

const emits = defineEmits([
                            "update:todo",
                            "delete:todo",
                            "enter"
                          ]);

let hover = ref(false);

onMounted(() => {
  console.log(props.todo)
  if (props.todo.done) {
    anim.value.play();
  }
});

const handleCheckboxChange = (event: Event) => {
  
  const target = event.target as HTMLInputElement;
  const newTodo = { ...props.todo, done: Boolean(target.checked) };
  emits('update:todo', newTodo);
  console.log('checkbox changed', newTodo);


  if (newTodo.done) {
    anim.value.goToAndPlay(0, true);
    anim.value.setDirection(1);
  } else {
    anim.value.setDirection(-1);
    anim.value.goToAndPlay(anim.value.getDuration(true), true);
  }
  anim.value.play();
};

const handleTextChange = (event: Event) => {
  const target = event.target as HTMLInputElement;
  const newTodo = { ...props.todo, text: target.value };
  emits('update:todo', newTodo);
  console.log('text changed', newTodo);
};

const handleDeleteTodo = () => {
  emits('delete:todo', props.todo.id);
  console.log('delete todo :', props.todo.id);
};

</script>


<template>
  <div class="todo">

    <textarea v-bind:value="todo.text" @input="handleTextChange" name="" id=""></textarea>

    <button class="deleteBtn" @click="handleDeleteTodo">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
      </svg>
    </button> 

    <span class="done">
      <label :for="'done' + props.todo.id">
        <LottieAnimation class="check"
          :animation-data="checkJSON"
          :auto-play="false"
          :loop="false"
          :speed="1"
          ref="anim"
          @mouseenter="hover = true"
          @mouseleave="hover = false"
          :class="{ 'check-done': hover }" />   
      </label>
      <input v-bind:checked="todo.done" v-on:change="handleCheckboxChange" :id="'done' + props.todo.id" name="done" type="checkbox" />
    </span>
    
    
    <!-- <input class="text-box" /> 
    -->
  </div>
</template>

<!--
    Le style du composant est encapsulé (scoped), 
    c'est-à-dire que chaque règle définie ici ne s'applique que sur ce composant
    Dans les faits, Vue.js va créer un hash unique à chaque composant 
    et suffixer nos règles de style avec ce hash 
 -->
<style scoped>
input.text-box {
  border: 1px solid black;
  padding: 0.3rem;
  border-radius: 12px;
  transition: all 0.2s ease-in-out;
  flex: 1 0;
}

.todo {
  position: relative;
  height: fit-content;
  min-height: 4rem;
  border-radius: 0.25rem;
  background: #FFF;
  box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.25);
  padding: 0.25rem;
  display: flex;
  flex-direction: row;
  gap: 1.25rem;
}

textarea {
  width: 100%;
  min-height: 100%;
  padding: 0.15rem;
  margin: 0;
  border: 0;
  box-shadow: rgba(99, 99, 99, 0.1) 0px 2px 8px 0px;
  resize: none;
  font-family: 'Figtree', sans-serif;
}
textarea:focus {
  outline: none;
}


.deleteBtn {
  position: absolute;
  bottom: 0.15rem;
  right: 0.15rem;
  background-color: transparent;
  border: none;
  color: red;
  cursor: pointer;
  padding: 0;
  margin: 0;
  width: 1rem;
  height: 1rem;
  display: flex;
  justify-content: center;
  align-items: center;
}

.done {
  position: relative;
  top: 0.5rem;
  right: 0.4rem;
  text-decoration: line-through;
}

.check-done {
  cursor: pointer;
}

.done input {
  display: none;
}

.check {
  height: 3rem;
  opacity: 0.6;
  margin: 0;
  padding: 0;
  display: grid;
  transform: translateY(-10%);
  place-items: center;
  transition: all 0.2s ease-in-out;
} 

.checked { opacity: 0.9 }
</style>
