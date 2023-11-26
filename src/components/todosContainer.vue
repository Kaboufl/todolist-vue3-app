<script setup lang="ts">
    import TodoItem from '@/components/TodoItem.vue';
    import type { Todo } from '@/models/Todo.model';
    import type { Categorie } from "@/models/Categorie.model";

    import _ from 'lodash';

    import { ref } from 'vue';

    /*const categorieInfo = defineProps({
        categorie: {
            type: Object as () => Categorie,
            required: true,
        },
    })
    */

    const props = defineProps<{ categorie: Categorie, todos: Todo[] }>()

    const newTodo = ref<Partial<Todo>>({
        done: false,
        category: props.categorie.idCategorie,
        text: ''
    });

    const showNewField = ref(false);

    const emits = defineEmits([
        "update:todo",
        "delete:todo",
        "delete:category",
        "newTodo"
    ]);

    const passNewTodo = () => {
        if (newTodo.value.text === '') {
            return;
        }
        showNewField.value = false;
        console.log(newTodo.value)
        const newTodoValue = { ...newTodo.value };
        emits('newTodo', newTodoValue);
        newTodo.value.text = '';
    }

    const passUpdateTodo = (newValues: Todo) => {
        console.log(newValues)
        emits('update:todo', newValues);
    }

    const passDeleteTodo = (id: number) => {
        console.log('delete todo :', id);
        emits('delete:todo', id);
    }

    const passDeleteCategory = (id: number) => {
        console.log('delete category :', id);
        emits('delete:category', id);
    }

    //const todos = ref<Todo[]>([]);
</script>

<template>
    <div class="todosContainer" :style="'background-color:'+categorie.hex_color+';'">
        <span class="spacer"></span>
        <span class="categorieTitle">
            <h2 class="title">{{ categorie.libelle }}</h2>
            <button class="deleteBtn" @click="passDeleteCategory(categorie.idCategorie)">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
                </svg>
            </button> 
        </span>
        <div class="todos">
            <template v-for="(todo, index) in todos" :key="index">
                <TodoItem :todo="todo" :index="index"
                    @update:todo="($event: Todo) => passUpdateTodo($event)"
                    @delete:todo="($event: number) => passDeleteTodo($event)"></TodoItem>
            </template>

            <div class="addTodo">

                <button class="addBtn" @click="showNewField = !showNewField" v-show="!showNewField">
                    <svg height="100%" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                    </svg>
                </button>

                <input class="newTodo" v-show="showNewField" type="text" v-model="newTodo.text" @keyup.enter="passNewTodo" placeholder="Ajouter une tâche" />

            </div>
        </div>
    </div>
</template>

<style>

.categorieTitle {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
}

.title {
    text-align: left;
    margin-left: 1rem;
    color: white;
    text-shadow: black 0.1em 0.1em 0.2em;
    font-family: 'Figtree', sans-serif;
}

.todosContainer {
    position: relative;
    width: 100%;
    height: fit-content;
    background-color: #59B4D1;
    z-index: 0;
    margin-bottom: 1rem;
    border-radius: 0.25rem;
}
.spacer {
    position: absolute;
    top: 0;
    width: 100%;
    height: 0.5rem;
    border-radius: 0.25rem 0.25rem 0rem 0rem;
    background: rgba(0, 0, 0, 0.10);
}

.todos {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    padding: 0.5rem;
    margin: 0.5rem;
    border-radius: 0.25rem;
}

.addTodo {
    position: relative;
    height: fit-content;
    min-height: 2rem;
    border-radius: 0.25rem;
    background: #FFF;
    box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.25);
    padding: 0.25rem;
    display: grid;
    place-items: center;
    gap: 1.25rem;
}

.addBtn {
    background-color: transparent;
    border: none;
    color: rgba(0, 0, 0, 0.5);
    cursor: pointer;
    padding: 0;
    margin: 0;
    width: 4rem;
    height: 4rem;
    display: flex;
    justify-content: center;
    align-items: center;
}

.deleteBtn {
    background-color: transparent;
    border: none;
    color: red;
    cursor: pointer;
    margin: 0;
    margin-right: 0.75rem;
    padding: 0;
    width: 1.8rem;
    height: 1.8rem;
    opacity: 0.8;
    display: flex;
    justify-content: center;
    align-items: center;
}
.deleteBtn svg {
    width: 1.8rem;
    height: 1.8rem;
}

.newTodo {
    width: 100%;
    min-height: 100%;
    padding: 0.15rem;
    margin: 0;
    border: 0;
    box-shadow: rgba(99, 99, 99, 0.1) 0px 2px 8px 0px;
    resize: none;
    font-family: 'Figtree', sans-serif;
    font-size: 1.5rem;
}

</style>