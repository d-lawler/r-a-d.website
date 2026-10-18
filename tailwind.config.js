module.exports = {
  content: [
    'components/**/*.{vue,js}',
    'plugins/**/*.{js,ts}',
    'app.vue'
  ],
  theme: {
    extend: {
      colors: {
        'rad-dark': '#222222',
        'rad-light': '#ffffff',
      },
      fontFamily: {
        display: ['"Helvetica Now Display"', 'system-ui', '-apple-system', 'sans-serif'],
        text: ['"Helvetica Now Text"', 'system-ui', '-apple-system', 'sans-serif'],
        micro: ['"Helvetica Now Micro"', 'system-ui', '-apple-system', 'sans-serif'],
        sans: ['"Helvetica Now Text"', 'system-ui', '-apple-system', 'sans-serif'],
      },
      fontSize: {
        'xs': ['0.75rem', { lineHeight: '1.5' }],
        'sm': ['0.875rem', { lineHeight: '1.5' }],
        'base': ['1rem', { lineHeight: '1.5' }],
        'lg': ['1.125rem', { lineHeight: '1.5' }],
        'xl': ['1.25rem', { lineHeight: '1.5' }],
        '2xl': ['1.5rem', { lineHeight: '1.25' }],
        '3xl': ['1.875rem', { lineHeight: '1.25' }],
        '4xl': ['2.25rem', { lineHeight: '1.25' }],
        '5xl': ['3rem', { lineHeight: '1.25' }],
        '6xl': ['3.75rem', { lineHeight: '1.25' }],
        '7xl': ['4.5rem', { lineHeight: '1.25' }],
      },
      gridTemplateColumns: {
        '6': 'repeat(6, minmax(0, 1fr))',
        '12': 'repeat(12, minmax(0, 1fr))',
      },
      spacing: {
        '2.5': '10px',
        '5': '20px',
        'gutter': '10px',
        'margin': '20px',
      },
      gap: {
        'gutter': '10px',
      },
      padding: {
        'row': '10px',
        'margin': '20px',
      },
      maxWidth: {
        'container': '1440px',
        'none': 'none',
        'full': '100%',
      },
    },
  },
  plugins: [
    function({ addUtilities }) {
      addUtilities({
        '.max-w-fluid': {
          'max-width': 'none !important',
        },
      })
    },
  ],
}
