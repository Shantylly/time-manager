<script setup lang="ts">
import { ref } from 'vue';
import instance from '../composables/api';
import { useSidebar } from '../composables/useSidebar';

const fullname = ref(sessionStorage.getItem('fullname'))
const id = ref(sessionStorage.getItem('userId'))

const dropdownOpen = ref(false)
const { isOpen } = useSidebar()
function logout() {
  sessionStorage.removeItem('userId')
  sessionStorage.removeItem('token')
  sessionStorage.removeItem('expirationDate')
  sessionStorage.removeItem('role')
  sessionStorage.removeItem('fullname')
  instance.defaults.headers.common.Authorization = null
}
</script>

<template>
  <header
    class="flex items-center justify-between px-6 py-4 bg-white border-b-4 border-indigo-600"
  >
    <div class="flex items-center">
      <button
        class="text-gray-500 focus:outline-none lg:hidden"
        @click="isOpen = true"
      >
        <svg
          class="w-6 h-6"
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M4 6H20M4 12H20M4 18H11"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </button>
    </div>

    <div class="flex items-center">
      <span class="text-sm text-gray-700 mr-4">{{ fullname }}</span>
      <div class="relative">
        <button
          class="relative z-10 block w-8 h-8 overflow-hidden rounded-full shadow focus:outline-none"
          @click="dropdownOpen = !dropdownOpen"
        >
          <img
            class="object-cover w-full h-full"
            src="../../public/icons8-user-96.png"
            alt="Your avatar"
          >
        </button>

        <div
          v-show="dropdownOpen"
          class="fixed inset-0 z-10 w-full h-full"
          @click="dropdownOpen = false"
        />

        <transition
          enter-active-class="transition duration-150 ease-out transform"
          enter-from-class="scale-95 opacity-0"
          enter-to-class="scale-100 opacity-100"
          leave-active-class="transition duration-150 ease-in transform"
          leave-from-class="scale-100 opacity-100"
          leave-to-class="scale-95 opacity-0"
        >
          <div
            v-show="dropdownOpen"
            class="absolute right-0 z-20 w-48 py-2 mt-2 bg-white rounded-md shadow-xl"
          >
            <router-link
              :to="{ name: 'Profile', params: { id } }"
              class="block px-4 py-2 text-sm text-gray-700 hover:bg-indigo-600 hover:text-white"
            >
              Profile
            </router-link>
            <router-link
              to="/"
              class="block px-4 py-2 text-sm text-gray-700 hover:bg-indigo-600 hover:text-white"
              @click="logout()"
            >
              Log out
            </router-link>
          </div>
        </transition>
      </div>
    </div>
  </header>
</template>
