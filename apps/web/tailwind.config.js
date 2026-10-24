/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./components/**/*.{js,vue,ts}",
    "./layouts/**/*.vue",
    "./pages/**/*.vue",
    "./plugins/**/*.{js,ts}",
    "./app.vue",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#6366F1',
          hover: '#4F46E5',
        },
        accent: '#22D3EE',
        dark: {
          bg: '#0B1020',
          surface: '#151C2F',
          border: '#283247',
          text: '#F8FAFC',
        }
      }
    },
  },
  plugins: [],
}

