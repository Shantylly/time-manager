<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { toast } from 'vue3-toastify'
import 'vue3-toastify/dist/index.css'
import Loading from '../components/Loading.vue'
import instance from '../composables/api'
import router from '../router'

interface User {
  data: {
    address: string
    firstname: string
    id: number
    genre: string
    lastname: string
    mail: string
    phone: string
    role: string
    team_id: number
  }
}

interface Team {
  id: number
  name: string
  manager_id: number
  manager_name: string
  users: Array<User>
}

const pageLoading = ref(true)
const teams = ref<Team[]>([])
const role = ref(sessionStorage.getItem('role'))
const managers = ref<User[]>([])
const noTeamUsers = ref<User[]>([])
const openModal = ref(false)
const isCreating = ref(false)
const isDeleting = ref(false)
const newTeamName = ref('')
const newTeamManagerId = ref()
const changeManagerId = ref<{ [team_id: number]: number }>({})
const isChanging = ref(false)

onMounted(async () => {
  if (role.value === 'User')
    router.push('/dashboard')
  const response = await instance.get('/teamsUsers')
  const users = await instance.get('/users')
  for (let i = 0; i < response.data.data.length; i++) {
    const element: Team = response.data.data[i]
    const manager = users.data.data.find((user: { id: any }) => user.id === element.manager_id)
    const manager_name = manager ? `${manager.firstname} ${manager.lastname}` : 'No Manager'
    element.manager_name = manager_name
    if (role.value === 'Manager' && sessionStorage.getItem('userId')) {
      if (element.manager_id.toString() === sessionStorage.getItem('userId')) {
        teams.value.push(element)
        changeManagerId.value[element.id] = element.manager_id
      }
    }
    else {
      teams.value.push(element)
      changeManagerId.value[element.id] = element.manager_id
    }
  }
  for (let i = 0; i < users.data.data.length; i++) {
    const user = users.data.data[i]
    const userInfo: User = {
      data: {
        address: user.address,
        firstname: user.firstname,
        id: user.id,
        genre: user.genre,
        lastname: user.lastname,
        mail: user.mail,
        phone: user.phone,
        role: user.role,
        team_id: user.team_id,
      },
    }
    if (!user.team_id) {
      if (user.role === 'User')
        noTeamUsers.value.push(userInfo)
      else
        managers.value.push(userInfo)
    }
  }
  teams.value.sort((a, b) => a.id - b.id)
  pageLoading.value = false
})

async function createTeam() {
  let teamNameTaken = false
  for (let i = 0; i < teams.value.length; i++) {
    const element = teams.value[i]
    if (newTeamName.value.toLowerCase() === element.name.toLowerCase())
      teamNameTaken = true
  }
  if (!newTeamManagerId.value || !newTeamName.value) {
    toast.error('Missing Informations', {
      autoClose: 1000,
    })
  }
  else if (teamNameTaken) {
    toast.error('Team already exists', {
      autoClose: 1000,
    })
  }
  else {
    isCreating.value = true
    await instance.post('/teams', {
      name: newTeamName.value,
      manager_id: newTeamManagerId.value,
    })
    isCreating.value = false
    openModal.value = false
    router.go(0)
  }
  toast.success('Team has been created', {
    autoClose: 1000,
  })
}

async function deleteTeam(id: number) {
  isDeleting.value = true
  const users = teams.value.find(team => team.id === id)?.users
  if (users) {
    for (let i = 0; i < users.length; i++) {
      const element = users[i]
      await instance.patch(`/users/${element.data.id}`, { team_id: null })
    }
  }
  await instance.delete(`/teams/${id}`)
  isDeleting.value = false
  router.go(0)
  toast.success('Team has been deleted', {
    autoClose: 1000,
  })
}

async function changeManager(team_id: number) {
  isChanging.value = true
  await instance.patch(`/teams/${team_id}`, { manager_id: changeManagerId.value[team_id] })
  isChanging.value = false
  router.go(0)
  toast.success('Manager has been changed', {
    autoClose: 1000,
  })
}
</script>

<template>
  <div v-if="!pageLoading" class="flex px-6 bg-gray-200">
    <div class="w-full p-6 bg-white rounded-md shadow-md">
      <div class="flex items-center justify-between border-b-4 border-indigo-600 pb-5">
        <div class="flex">
          <h1 class="text-2xl font-semibold text-gray-700 m-2 flex-1">
            TEAMS
          </h1>
          <img v-if="isChanging" class="h-4 w-4 mt-4" src="../../public/black_oval.svg" alt="Loading icon">
        </div>
        <svg
          class="w-10 h-10"
          viewBox="0 0 512 512"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <image href="../../public/time-watch-svgrepo-com.svg" x="0" y="0" height="100%" width="100%" />
        </svg>
      </div>
      <div v-for="team in teams" :key="team.id" class="m-4">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-2xl font-semibold text-gray-700 mt-3">
              {{ team.name }}
            </h4>
            <span v-if="role === 'General Manager'" class="text-sm text-gray-700 mb-2">{{ `managed by ${team.manager_name}` }}</span>
          </div>
          <div class="flex inline-block">
            <label class="block mt-4">
              <select
                v-if="role === 'General Manager'"
                id="role" v-model="changeManagerId[team.id]"
                class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
              >
                <option v-for="manager in managers" :key="manager.data.id" :value="manager.data.id">
                  {{ `${manager.data.firstname} ${manager.data.lastname}` }}
                </option>
              </select>
            </label>
            <button
              v-if="role === 'General Manager'"
              class="m-2 mt-5 mr-0 px-4 py-2 font-medium tracking-wide text-white capitalize transition-colors duration-200 transform bg-indigo-600 rounded-md hover:bg-indigo-500 focus:outline-none focus:bg-indigo-500"
              @click="changeManager(team.id)"
            >
              <img v-if="isDeleting" class="inline-flex items-center space-x-2 h-4 w-4 mb-1 mr-1" src="../../public/oval.svg" alt="Loading icon">
              Change Manager
            </button>
            <button
              v-if="role === 'General Manager'"
              class="m-2 mt-5 mr-0 px-4 py-2 font-medium tracking-wide text-white capitalize transition-colors duration-200 transform bg-red-600 rounded-md hover:bg-red-500 focus:outline-none focus:bg-red-500"
              @click="deleteTeam(team.id)"
            >
              <img v-if="isDeleting" class="inline-flex items-center space-x-2 h-4 w-4 mb-1 mr-1" src="../../public/oval.svg" alt="Loading icon">
              Delete team
            </button>
          </div>
        </div>

        <div class="my-6 overflow-hidden bg-white rounded-md shadow">
          <table class="w-full text-left border-collapse">
            <thead class="border-b">
              <tr>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-indigo-700"
                >
                  Profile
                </th>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-indigo-700"
                >
                  Name
                </th>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-indigo-700"
                >
                  Mail
                </th>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-indigo-700"
                >
                  Phone
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(user, index) in team.users"
                :key="index"
                class="hover:bg-gray-200"
              >
                <td class="px-6 py-4 text-gray-500 border-b">
                  <button
                    class="px-4 py-2 font-medium tracking-wide text-white capitalize transition-colors duration-200 transform bg-gray-600 rounded-md hover:bg-gray-500 focus:outline-none focus:bg-gray-500"
                    @click="router.push({ name: 'Profile', params: { id: user.data.id } })"
                  >
                    {{ 'Update' }}
                  </button>
                </td>
                <td class="px-6 py-4 text-lg text-gray-700 border-b">
                  {{ `${user.data.firstname} ${user.data.lastname}` }}
                </td>
                <td class="px-6 py-4 text-lg text-gray-700 border-b">
                  {{ `${user.data.mail}` }}
                </td>
                <td class="px-6 py-4 text-lg text-gray-700 border-b">
                  {{ `${user.data.phone}` }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="m-4">
        <h4 class="text-2xl font-semibold text-gray-700 mt-3">
          {{ 'No team accounts' }}
        </h4>
        <div class="my-6 overflow-hidden bg-white rounded-md shadow">
          <table class="w-full text-left border-collapse">
            <thead class="border-b">
              <tr>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-red-700"
                >
                  Profile
                </th>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-red-700"
                >
                  name
                </th>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-red-700"
                >
                  Mail
                </th>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-red-700"
                >
                  Phone
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(user, index) in noTeamUsers"
                :key="index"
                class="hover:bg-gray-200"
              >
                <td class="px-6 py-4 text-gray-500 border-b">
                  <!-- <router-link :to="{ name: 'Profile', params: { id: user.data.id } }" class="text-indigo-600 hover:text-indigo-900">
                    Update
                  </router-link> -->
                  <button
                    class="px-4 py-2 font-medium tracking-wide text-white capitalize transition-colors duration-200 transform bg-red-600 rounded-md hover:bg-red-500 focus:outline-none focus:bg-red-500"
                    @click="router.push({ name: 'Profile', params: { id: user.data.id } })"
                  >
                    {{ 'Update' }}
                  </button>
                </td>
                <td class="px-6 py-4 text-lg text-gray-700 border-b">
                  {{ `${user.data.firstname} ${user.data.lastname}` }}
                </td>
                <td class="px-6 py-4 text-lg text-gray-700 border-b">
                  {{ `${user.data.mail}` }}
                </td>
                <td class="px-6 py-4 text-lg text-gray-700 border-b">
                  {{ `${user.data.phone}` }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="m-4">
        <h4 class="text-2xl font-semibold text-gray-700 mt-3">
          {{ 'Managers' }}
        </h4>
        <div class="my-6 overflow-hidden bg-white rounded-md shadow">
          <table class="w-full text-left border-collapse">
            <thead class="border-b">
              <tr>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-green-700"
                >
                  name
                </th>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-green-700"
                >
                  Mail
                </th>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-green-700"
                >
                  Phone
                </th>
                <th
                  class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-green-700"
                >
                  Role
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(user, index) in managers"
                :key="index"
                class="hover:bg-gray-200"
              >
                <td class="px-6 py-4 text-lg text-gray-700 border-b">
                  {{ `${user.data.firstname} ${user.data.lastname}` }}
                </td>
                <td class="px-6 py-4 text-lg text-gray-700 border-b">
                  {{ `${user.data.mail}` }}
                </td>
                <td class="px-6 py-4 text-lg text-gray-700 border-b">
                  {{ `${user.data.phone}` }}
                </td>
                <td class="px-6 py-4 text-gray-700 border-b">
                  {{ user.data.role }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div v-if="role === 'General Manager'" class="flex m-5 ml-0 mb-0 w-1/5">
        <button
          class="flex-1 m-1 ml-0 px-4 py-2 font-medium tracking-wide text-white capitalize transition-colors duration-200 transform bg-indigo-600 rounded-md hover:bg-indigo-500 focus:outline-none focus:bg-indigo-500"
          @click="openModal = true"
        >
          Create team
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
              <div class="flex items-center justify-between border-b-4 border-indigo-600 pb-5">
                <h4 class="text-2xl font-semibold text-gray-700 mt-3">
                  Create Team
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
                <div class="m-4">
                  <label class="block">
                    <span class="text-sm text-gray-700 mb-2">Name</span>
                    <input
                      v-model="newTeamName"
                      class="w-full block mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
                    >
                  </label>
                  <label class="block mt-3">
                    <span class="text-sm text-gray-700">Manager</span>
                    <select
                      id="role" v-model="newTeamManagerId"
                      class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
                    >
                      <option v-for="manager in managers" :key="manager.data.id" :value="manager.data.id">
                        {{ `${manager.data.firstname} ${manager.data.lastname}` }}
                      </option>
                    </select>
                  </label>
                </div>
              </div>

              <!-- Footer -->
              <div class="flex justify-end pt-3">
                <button
                  class="p-3 px-6 py-3 mr-2 text-grey-500 bg-transparent rounded-lg hover:bg-gray-100 hover:text-grey-400 focus:outline-none"
                  @click="openModal = false"
                >
                  Close
                </button>
                <button
                  class="px-6 py-3 font-medium tracking-wide text-white bg-indigo-600 rounded-md hover:bg-indigo-500 focus:outline-none"
                  @click="createTeam()"
                >
                  <img v-if="isCreating" class="inline-flex items-center space-x-2 h-4 w-4 mb-1 mr-1" src="../../public/oval.svg" alt="Loading icon">
                  Create
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div v-else>
    <Loading />
  </div>
</template>
