<script setup lang="ts">
import ApexCharts from 'apexcharts';
import { onMounted, ref } from 'vue';

const sumArray = (arr: number[]) => arr.reduce((acc, curr) => acc + curr, 0)

function generateArray() {
  const array = []
  let remainingSum = 35

  for (let i = 0; i < 5; i++) {
    const min = Math.max(6)
    const max = Math.min(8)
    const randomNumber = Math.floor(Math.random() * (max - min + 1)) + min
    array.push(randomNumber)
    remainingSum -= randomNumber
  }

  // Generate two zeros at the end
  array.push(0, 0)

  return array
}

const options = {
  series: [
    {
      data: generateArray(),
    },
  ],
  chart: {
    height: 350,
    type: 'bar',
  },
  colors: [
    '#008FFB',
    '#FF5733',
    '#33FF57',
    '#FF33A7',
    '#33A7FF',
    '#A7FF33',
    '#A733FF',
  ],
  plotOptions: {
    bar: {
      columnWidth: '45%',
      distributed: true,
    },
  },
  dataLabels: {
    enabled: false,
  },
  legend: {
    show: false,
  },
  xaxis: {
    categories: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    labels: {
      style: {
        colors: ['#008FFB'],
        fontSize: '12px',
      },
    },
  },
}
const sum = ref(sumArray(options.series[0].data))
onMounted(() => {
  const chart = new ApexCharts(document.querySelector('#chart'), options)
  chart.render()
})
</script>

<template>
  <div id="chart" />
  <div>Total worked hours: {{ sum }}</div>
</template>
