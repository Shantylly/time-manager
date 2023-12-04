<script setup lang="ts">
import ApexCharts from 'apexcharts'
import { onMounted, onUnmounted, ref } from 'vue'
import Loading from '../components/Loading.vue'
import instance from '../composables/api'
import Calendar from '../views/calendar.vue'

const pageLoading = ref(false)
const role = ref(sessionStorage.getItem('role'))

interface User {
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

interface Team {
  id: number
  name: string
  manager_id: number
}

function generateData(count: number, yrange: { min: any; max: any }) {
  let i = 0
  const series = []
  while (i < count) {
    const x = (i + 1).toString()
    const y
  = Math.floor(Math.random() * (yrange.max - yrange.min + 1)) + yrange.min

    series.push({
      x,
      y,
    })
    i++
  }
  return series
}
const teams = ref<Team[]>([])
const users = ref<User[]>([])

const options3 = {
  series: [{
    name: 'Presence',
    data: generateData(12, {
      min: 9,
      max: 15,
    }),
  },
  {
    name: 'Absence',
    data: generateData(12, {
      min: 0,
      max: 3,
    }),
  },
  ],
  chart: {
    height: 350,
    type: 'heatmap',
  },
  dataLabels: {
    enabled: false,
  },
  colors: ['#0BDA51', '#FF5733'],
  title: {
    text: 'Presence and Absence of Employees',
  },
}

const options2 = {
  series: [{
    name: 'Present Workforce',
    type: 'column',
    data: [10, 10, 10, 12, 15, 9, 10, 10, 8, 13, 10, 10],
  }, {
    name: 'Maximum Workforce',
    type: 'line',
    data: [15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15],
  }],
  chart: {
    height: 350,
    type: 'line',
  },
  stroke: {
    width: [0, 4],
  },
  title: {
    text: 'Traffic Sources',
  },
  dataLabels: {
    enabled: true,
    enabledOnSeries: [1],
  },
  labels: ['01 Jan 2001', '02 Jan 2001', '03 Jan 2001', '04 Jan 2001', '05 Jan 2001', '06 Jan 2001', '07 Jan 2001', '08 Jan 2001', '09 Jan 2001', '10 Jan 2001', '11 Jan 2001', '12 Jan 2001'],
  xaxis: {
    type: 'datetime',
  },
  yaxis: [{
    title: {
      text: 'Result',
    },

  }, {
    opposite: true,
    title: {
      text: 'Expected Result',
    },
  }],
}

const pieoptions = {
  series: [0],
  chart: {
    width: 380,
    type: 'pie',
  },
  title: {
    text: 'Users by Teams',
  },
  labels: [],
  responsive: [{
    breakpoint: 480,
    options: {
      chart: {
        width: 200,
      },
      legend: {
        position: 'bottom',
      },
    },

  }],
}

const pieoptions2 = {
  series: [0],
  chart: {
    width: 380,
    type: 'pie',
  },
  title: {
    text: 'Users by Gender',
  },
  labels: [''],
  responsive: [{
    breakpoint: 480,
    options: {
      chart: {
        width: 200,
      },
      legend: {
        position: 'bottom',
      },
    },
  }],
}

const pieoptions3 = {
  series: [{
    name: 'Average Presence',
    data: [12, 12, 13, 15, 12, 13, 14, 11, 11, 12, 13, 12],
  }],
  chart: {
    height: 350,
    type: 'radar',
  },
  dataLabels: {
    enabled: true,
  },
  plotOptions: {
    radar: {
      size: 140,
      polygons: {
        strokeColors: '#e9e9e9',
        fill: {
          colors: ['#f8f8f8', '#fff'],
        },
      },
    },
  },
  title: {
    text: 'Average Presence of Employees per Month',
  },
  colors: ['#FF4560'],
  markers: {
    size: 4,
    colors: ['#fff'],
    strokeColor: '#FF4560',
    strokeWidth: 2,
  },
  tooltip: {
    y: {
      formatter(val: number) {
        return val
      },
    },
  },
  xaxis: {
    categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  },
  yaxis: {
    tickAmount: 15,
    labels: {
      formatter(val: number, i: number) {
        if (i % 2 === 0)
          return val
        else
          return ''
      },
    },
  },
}

let pieChart: ApexCharts | null = null
let pieChart2: ApexCharts | null = null
let pieChart3: ApexCharts | null = null
let chart: ApexCharts | null = null
let chart2: ApexCharts | null = null

let onPhone = false
if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))
  onPhone = true

onMounted(async () => {
  try {
    pageLoading.value = true
    const pieresponse = await instance.get('teams')
    const response = await instance.get('users')
    const userbyTeam = await instance.get('users_by_team')
    pageLoading.value = false
    if (response.status === 200 && pieresponse.status === 200) {
    // first pie

      pieoptions.labels = pieresponse.data.data.map((team: { name: any }) => team.name)
      // Initialize an empty array to store user_count values
      const userCountArray: number[] = []
      // Iterate through the userbyTeam.data.team array
      for (let i = 0; i < userbyTeam.data.teams.length; i++) {
        // Get the user_count value from the current object and add it to the new array
        userCountArray.push(userbyTeam.data.teams[i].user_count)
      }

      pieoptions.series = userCountArray
      // Now, userCountArray contains user_count values from each object in userbyTeam.data.team
      pieChart = new ApexCharts(document.querySelector('#pie'), pieoptions)
      pieChart.render()
      // second pie
      const userCountByGenre: { [key: number]: number } = {}
      for (let i = 0; i < response.data.data.length; i++) {
        const user = response.data.data[i]
        const { genre } = user

        // If the team_id is not in the map, initialize it with a count of 1
        if (!userCountByGenre[genre]) {
          userCountByGenre[genre] = 1
        }
        else {
          // If the team_id is already in the map, increment the count
          userCountByGenre[genre]++
        }
      }
      pieoptions2.series = Object.values(userCountByGenre)
      pieoptions2.labels = Object.keys(userCountByGenre)

      pieChart2 = new ApexCharts(document.querySelector('#pie2'), pieoptions2)
      pieChart2.render()

      // third pie
      pieChart3 = new ApexCharts(document.querySelector('#pie3'), pieoptions3)
      pieChart3.render()
      chart = new ApexCharts(document.querySelector('#chart'), options2)
      chart.render()
      chart2 = new ApexCharts(document.querySelector('#chart2'), options3)
      chart2.render()

      teams.value = pieresponse.data.data
      users.value = response.data.data
    }
    else {
      console.error('Failed to fetch data')
    }
  }
  catch (error) {
    console.error('An error occurred:', error)
  }
})
onUnmounted(async () => {
  try {
    if (pieChart)
      pieChart.destroy()

    if (pieChart2)
      pieChart2.destroy()

    if (pieChart3)
      pieChart3.destroy()

    if (chart)
      chart.destroy()

    if (chart2)
      chart2.destroy()
  }
  catch (error) {
    console.error('An error occurred:', error)
  }
})
</script>

<template>
  <div v-if="!pageLoading" class="mb-7 flex px-6 bg-gray-200">
    <div class="w-full p-6 bg-white rounded-md shadow-md">
      <div class="mb-3 flex items-center justify-between border-b-4 border-indigo-600 pb-5">
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
  <div v-if="!pageLoading" class="px-6 bg-gray-200">
    <div class="mb-7 w-full p-6 bg-white rounded-md shadow-md">
      <div class="flex items-center justify-between border-b-4 border-indigo-600 pb-5">
        <h1 class="text-2xl font-semibold text-gray-700 m-2 flex-1">
          Members
        </h1>
        <svg
          class="w-10 h-10"
          viewBox="0 0 512 512"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <image href="../../public/time-watch-svgrepo-com.svg" x="0" y="0" height="100%" width="100%" />
        </svg>
      </div>
      <div class="flex flex-col mt-8">
        <div class="py-2 -my-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
          <div class="inline-block min-w-full overflow-hidden align-middle border-b border-gray-200 shadow sm:rounded-lg">
            <table class="min-w-full">
              <thead>
                <tr>
                  <th class="px-6 py-3 text-xs font-medium leading-4 tracking-wider text-left text-gray-500 uppercase border-b border-gray-200 bg-gray-50">
                    Name
                  </th>
                  <th v-if="!onPhone" class="px-6 py-3 text-xs font-medium leading-4 tracking-wider text-left text-gray-500 uppercase border-b border-gray-200 bg-gray-50">
                    Team Name
                  </th>
                  <th v-if="!onPhone" class="px-6 py-3 text-xs font-medium leading-4 tracking-wider text-left text-gray-500 uppercase border-b border-gray-200 bg-gray-50">
                    Role
                  </th>
                  <th v-if="!onPhone" class="px-6 py-3 text-xs font-medium leading-4 tracking-wider text-left text-gray-500 uppercase border-b border-gray-200 bg-gray-50">
                    Genre
                  </th>
                  <th class="px-6 py-3 border-b border-gray-200 bg-gray-50" />
                </tr>
              </thead>
              <tbody class="bg-white">
                <tr v-for="(u, index) in users" :key="index">
                  <td class="px-2 py-4 border-b border-gray-200 whitespace-nowrap">
                    <div class="flex items-center">
                      <div class="flex-shrink-0 w-10 h-10">
                        <img
                          class="w-10 h-10 rounded-full"
                          src="../../public/icons8-user-96.png"
                          alt=""
                        >
                      </div>
                      <div class="ml-4">
                        <div class="text-sm font-medium leading-5 text-gray-900">
                          {{ u.firstname }} {{ u.lastname }}
                        </div>
                        <div class="text-sm leading-5 text-gray-500">
                          {{ u.mail }}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td v-if="!onPhone" class="px-6 py-4 border-b border-gray-200 whitespace-nowrap">
                    <div class="text-sm leading-5 text-gray-900">
                      {{ teams.find(team => team.id === u.team_id)?.name ? teams.find(team => team.id === u.team_id)?.name : u.role !== 'User' ? 'Manager Team' : 'No Team' }}
                    </div>
                  </td>
                  <td v-if="!onPhone" class="px-6 py-4 border-b border-gray-200 whitespace-nowrap">
                    <span
                      v-if="u.role === 'Manager'"
                      class="inline-flex px-2 text-xs font-semibold leading-5 text-red-800 bg-red-100 rounded-full"
                    >{{ u.role }}
                    </span>
                    <span
                      v-else-if="u.role === 'User'"
                      class="inline-flex px-2 text-xs font-semibold leading-5 text-blue-800 bg-blue-100 rounded-full"
                    >
                      {{ u.role }}</span>
                    <span
                      v-else-if="u.role === 'General Manager'"
                      class="inline-flex px-2 text-xs font-semibold leading-5 text-orange-800 bg-orange-100 rounded-full"
                    >
                      {{ u.role }}</span>
                  </td>
                  <td v-if="!onPhone" class="px-6 py-4 text-sm leading-5 text-gray-500 border-b border-gray-200 whitespace-nowrap">
                    {{ u.genre }}
                  </td>
                  <td
                    :class="{
                      'px-6 py-4 text-sm font-medium leading-5 text-right border-b border-gray-200 whitespace-nowrap': !onPhone,
                      'px-4 py-2 text-sm font-medium leading-5 text-left border-b border-gray-200 whitespace-nowrap': onPhone,
                    }"
                  >
                    <router-link :to="{ name: 'PersonalDashboard', params: { id: u.id } }" class="text-indigo-600 hover:text-indigo-900">
                      View
                    </router-link>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div v-else>
    <Loading />
  </div>
  <div v-show="role !== 'User' && !pageLoading" class="px-6 bg-gray-200">
    <div class="px-6 bg-gray-200 w-full p-6 bg-white rounded-md shadow-md">
      <div class="flex items-center justify-between border-b-4 border-indigo-600 pb-5">
        <h1 class="text-2xl font-semibold text-gray-700 m-2 flex-1">
          Graphics
        </h1>
        <svg
          class="w-10 h-10"
          viewBox="0 0 512 512"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <image href="../../public/time-watch-svgrepo-com.svg" x="0" y="0" height="100%" width="100%" />
        </svg>
      </div>
      <div class="mt-3">
        <div style="display: flex;">
          <div id="pie" style="flex: 1;" />
          <div id="pie2" style="flex: 1;" />
          <div id="pie3" style="flex: 1;" />
        </div>
        <div id="chart" />
        <div id="chart2" />
      </div>
    </div>
  </div>
</template>
