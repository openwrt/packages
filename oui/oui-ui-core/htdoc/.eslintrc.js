module.exports = {
  globals: {
    process: true,
    __dirname: true
  },
  env: {
    browser: true,
    es2021: true
  },
  extends: [
    'eslint:recommended',
    'plugin:vue/vue3-essential'
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  plugins: [
    'vue'
  ],
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    'vue/no-multiple-template-root': 'off',
    'vue/multi-word-component-names': 'off',
    'linebreak-style': ['error', 'unix'],
    'quotes': ['error', 'single'],
    'brace-style': 'error',
    'comma-dangle': 'error',
    'comma-spacing': 'error',
    'keyword-spacing': 'error',
    'no-trailing-spaces': 'error',
    'no-unneeded-ternary': 'error',
    'space-before-function-paren': ['error', 'never'],
    'space-infix-ops': ['error', {'int32Hint': false}],
    'arrow-spacing': 'error',
    'no-var': 'error',
    'no-duplicate-imports': 'error',
    'space-before-blocks': 'error',
    'space-in-parens': ['error', 'never'],
    'no-multi-spaces': 'error',
    'eqeqeq': 'error',
    'indent': ['error', 2],
    'semi': ['error', 'never']
  }
}
