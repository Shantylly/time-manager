<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { toast } from 'vue3-toastify'
import 'vue3-toastify/dist/index.css'
import instance from '../composables/api'
import Calendar from '../views/calendar.vue'
import Header from './Header.vue'
import Loading from './Loading.vue'
import Sidebar from './Sidebar.vue'

const router = useRouter()
const email = ref('')
const address = ref('')
const first_name = ref('')
const last_name = ref('')
const phone_number = ref('')
const role = ref('')
const team_name = ref('')
const team_id = ref('')
const isLoading = ref(false)
const pageLoading = ref(true)
const isModifying = ref(false)
const openModal = ref(false)
const isDeleting = ref(false)
const route = useRoute()
const id = ref(route.params.id)
const idUser = route.params.id
const idCurrent = ref(sessionStorage.getItem('userId'))
const teams = ref<Team[]>([])
const roleUser = ref(sessionStorage.getItem('role'))

interface Team {
  name: string
  id: number
}

onMounted(async () => {
  if (id.value !== idCurrent.value) {
    if (roleUser.value === 'User')
      router.push('/dashboard')
  }
  try {
    const team_response = await instance.get('teams')
    for (let i = 0; i < team_response.data.data.length; i++) {
      const element = team_response.data.data[i]
      teams.value.push({ name: element.name, id: element.id })
    }
    const response = await instance.get(`users/${id.value}`)
    if (response.status === 200 && team_response.status === 200) {
      email.value = response.data.data.mail
      address.value = response.data.data.address
      phone_number.value = response.data.data.phone
      role.value = response.data.data.role
      first_name.value = response.data.data.firstname
      last_name.value = response.data.data.lastname
      if (response.data.data.team_id) {
        team_id.value = response.data.data.team_id
        team_name.value = team_response.data.data.filter((team: { id: any }) => team.id === response.data.data.team_id)[0].name
      }
      pageLoading.value = false
    }
    else {
      console.error('Failed to fetch data')
      pageLoading.value = false
    }
  }
  catch (error) {
    console.error('An error occurred:', error)
    pageLoading.value = false
  }
})

function save() {
  if (!email.value || !address.value || !phone_number.value) {
    toast.error('Fields are not all completed', {
      autoClose: 1000,
    })
    return
  }
  isLoading.value = !isLoading.value
  const userInformation = {
    address: address.value,
    mail: email.value,
    phone: phone_number.value,
    team_id: role.value !== 'User' ? null : team_id.value,
    role: role.value,
  }
  instance.put(`users/${id.value}`, userInformation)
    .then((response) => {
      isLoading.value = !isLoading.value
    })
    .catch((error) => {
      isLoading.value = !isLoading.value
      console.error('Erreur lors de l\'appel à l\'API :', error)
    })
}

let onPhone = false
if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))
  onPhone = true
</script>

<template>
  <div class="flex h-screen bg-gray-200 font-roboto">
    <Sidebar />

    <div class="flex-1 flex flex-col overflow-hidden">
      <Header />

      <main class="flex-1 overflow-x-hidden overflow-y-auto bg-gray-200">
        <div class="container mx-auto px-6 py-8">
          <div v-if="!pageLoading" class="mb-7 flex px-6 bg-gray-200">
            <div class="w-full p-6 bg-white rounded-md shadow-md">
              <div class="mb-3 flex items-center justify-between border-b-4 border-indigo-600 pb-5">
                <button v-if="onPhone" class="text-gray-700 hover:text-indigo-600 focus:outline-none focus:text-indigo-600">
                  <router-link to="/dashboard">
                    <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <image href="../../public/back-arrow-svgrepo-com.svg" x="0" y="0" height="100%" width="100%" />
                    </svg>
                  </router-link>
                </button>
                <span class="text-2xl font-semibold text-gray-700 m-2 flex-1">{{ 'Presence' }}</span>
                <svg
                  class="w-10 h-10"
                  viewBox="0 0 512 512"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <image href="../../public/time-watch-svgrepo-com.svg" x="0" y="0" height="100%" width="100%" />
                </svg>
              </div>
              <Calendar />
              <slot />
            </div>
          </div>
          <div v-if="!pageLoading" class="flex px-6 bg-gray-200">
            <div class="w-full p-6 bg-white rounded-md shadow-md">
              <div class="flex items-center justify-between border-b-4 border-indigo-600 pb-5">
                <button v-if="onPhone" class="text-gray-700 hover:text-indigo-600 focus:outline-none focus:text-indigo-600">
                  <router-link to="/dashboard">
                    <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <image href="../../public/back-arrow-svgrepo-com.svg" x="0" y="0" height="100%" width="100%" />
                    </svg>
                  </router-link>
                </button>
                <span class="text-2xl font-semibold text-gray-700 m-2 flex-1">{{ isModifying ? 'Update Information' : 'Profile' }}</span>
                <svg
                  class="w-10 h-10"
                  viewBox="0 0 512 512"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <image href="../../public/time-watch-svgrepo-com.svg" x="0" y="0" height="100%" width="100%" />
                </svg>
              </div>
              <div class="flex flex-col">
                <!-- Utilisation de flex-col pour empiler les éléments verticalement -->
                <form v-if="isModifying" class="mt-4 w-2/4 ml-1" @submit.prevent="save">
                  <div class="mb-3">
                    <div class="flex">
                      <button
                        class="flex-1 m-1 ml-0 px-4 py-2 font-medium tracking-wide text-white capitalize transition-colors duration-200 transform bg-red-600 rounded-md hover:bg-red-500 focus:outline-none focus:bg-red-500"
                        type="button"
                        @click="openModal = true"
                      >
                        <img v-if="isDeleting" class="inline-flex items-center space-x-2 h-4 w-4 mb-1 mr-1" src="../../public/oval.svg" alt="Loading icon">
                        Delete Account
                      </button>
                      <div
                        :class="`modal ${
                          !openModal && 'opacity-0 pointer-events-none'
                        } z-50 fixed w-full h-full top-0 left-0 flex items-center justify-center`"
                      >
                        <div
                          class="absolute w-full h-full bg-gray-900 opacity-50 modal-overlay"
                          @click="openModal = false"
                        />

                        <div
                          class="z-50 w-11/12 mx-auto overflow-y-auto bg-white rounded shadow-lg modal-container md:max-w-md"
                        >
                          <div
                            class="absolute top-0 right-0 z-50 flex flex-col items-center mt-4 mr-4 text-sm text-white cursor-pointer modal-close"
                          >
                            <svg
                              class="text-white fill-current"
                              xmlns="http://www.w3.org/2000/svg"
                              width="18"
                              height="18"
                              viewBox="0 0 18 18"
                            >
                              <path
                                d="M14.53 4.53l-1.06-1.06L9 7.94 4.53 3.47 3.47 4.53 7.94 9l-4.47 4.47 1.06 1.06L9 10.06l4.47 4.47 1.06-1.06L10.06 9z"
                              />
                            </svg>
                            <span class="text-sm">(Esc)</span>
                          </div>

                          <!-- Add margin if you want to see some of the overlay behind the modal -->
                          <div class="px-6 py-4 text-left modal-content">
                            <!-- Title -->
                            <div class="flex items-center justify-between pb-2">
                              <h4 class="text-2xl font-semibold text-gray-700 mt-3">
                                Confirm Delete
                              </h4>
                              <div class="z-50 cursor-pointer modal-close" @click="openModal = false">
                                <svg
                                  class="text-black fill-current"
                                  xmlns="http://www.w3.org/2000/svg"
                                  width="18"
                                  height="18"
                                  viewBox="0 0 18 18"
                                >
                                  <path
                                    d="M14.53 4.53l-1.06-1.06L9 7.94 4.53 3.47 3.47 4.53 7.94 9l-4.47 4.47 1.06 1.06L9 10.06l4.47 4.47 1.06-1.06L10.06 9z"
                                  />
                                </svg>
                              </div>
                            </div>

                            <!-- Body -->

                            <div class="text-gray-500">
                              Are you are sure to delete your account ?
                            </div>
                          </div>
                        </div>
                      </div>
                      <button
                        class="flex-1 m-1 px-4 py-2 font-medium tracking-wide text-white capitalize transition-colors duration-200 transform bg-green-600 rounded-md hover:bg-green-500 focus:outline-none focus:bg-green-500"
                        type="submit"
                      >
                        <img v-if="isLoading" class="inline-flex items-center space-x-2 h-4 w-4 mb-1 mr-1" src="../../public/oval.svg" alt="Loading icon">
                        {{ isLoading ? 'Loading' : 'Save Changes' }}
                      </button>
                    </div>
                  </div>
                  <label class="block">
                    <span class="text-sm text-gray-700">Email (has to be a valid mail)*</span>
                    <input
                      v-model="email"
                      type="email"
                      class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
                    >
                  </label>
                  <label class="block mt-3">
                    <span class="text-sm text-gray-700">Address *</span>
                    <input
                      v-model="address"
                      type="text"
                      class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
                    >
                  </label>
                  <label class="block mt-3">
                    <span class="text-sm text-gray-700">Phone Number (has to be 10 digit)*</span>
                    <input
                      id="phone"
                      v-model="phone_number" type="tel" name="phone" pattern="[0-9]{10}"
                      class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
                    >
                  </label>
                  <label v-if="idUser !== id" class="block mt-3">
                    <span class="text-sm text-gray-700">Role</span>
                    <select
                      id="role" v-model="role"
                      class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
                    >
                      <option v-for="roleChoice in ['User', 'Manager']" :key="roleChoice" :value="roleChoice">
                        {{ roleChoice }}
                      </option>
                    </select>
                  </label>
                  <label v-if="idUser !== id" class="block mt-3">
                    <span class="text-sm text-gray-700">Team</span>
                    <select
                      id="team_id" v-model="team_id"
                      class="custom-cursor block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
                      :disabled="role !== 'User'"
                    >
                      <option v-for="team in teams" :key="team.id" :value="team.id">
                        {{ team.name }}
                      </option>
                    </select>
                    <span v-if="role !== 'User'" class="text-sm text-gray-500">No team if role is manager</span>
                  </label>
                </form>

                <div v-else class="m-5">
                  <div class="grid grid-cols-1 gap-4">
                    <div class="flex flex-col">
                      <h4 class="text-2xl font-semibold text-gray-700 mt-3">
                        First Name
                      </h4>
                      <div class="text-gray-500 ml-2">
                        {{ first_name }}
                      </div>
                    </div>
                    <div class="flex flex-col">
                      <h4 class="text-2xl font-semibold text-gray-700 mt-3">
                        Last Name
                      </h4>
                      <div class="text-gray-500 ml-2">
                        {{ last_name }}
                      </div>
                    </div>
                    <div class="flex flex-col">
                      <h4 class="text-2xl font-semibold text-gray-700 mt-3">
                        Email
                      </h4>
                      <div class="text-gray-500 ml-2">
                        {{ email }}
                      </div>
                    </div>
                    <div class="flex flex-col">
                      <h4 class="text-2xl font-semibold text-gray-700 mt-3">
                        Phone
                      </h4>
                      <div class="text-gray-500 ml-2">
                        {{ phone_number }}
                      </div>
                    </div>
                    <div v-if="role === 'User'" class="flex flex-col">
                      <h4 class="text-2xl font-semibold text-gray-700 mt-3">
                        Team
                      </h4>
                      <div class="text-gray-500 ml-2">
                        {{ team_name ? team_name : 'You have no team yet' }}
                      </div>
                    </div>
                    <div class="flex flex-col">
                      <h4 class="text-2xl font-semibold text-gray-700 mt-3">
                        Role
                      </h4>
                      <div class="text-gray-500 ml-2">
                        {{ role }}
                      </div>
                    </div>
                    <div class="flex flex-col">
                      <h4 class="text-2xl font-semibold text-gray-700 mt-3">
                        Address
                      </h4>
                      <div class="text-gray-500 ml-2">
                        {{ address }}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div v-if="pageLoading">
            <Loading />
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<style>
/* Style pour le curseur personnalisé */
.custom-cursor[disabled] {
  cursor: not-allowed;
}
</style>
