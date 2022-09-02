# Eslint Config for React/Nextjs App

## Pre-requisits

- `@typescript-eslint/eslint-plugin`
- `@typescript-eslint/parser`
- `eslint`
- `eslint-config-airbnb`
- `eslint-plugin-react`

To install these: `yarn add -D @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint eslint-config-airbnb eslint-plugin-react`

Add these to the `package.json`:

```
"eslintConfig": {
  "extends": [
    "react-app",
    "react-app/jest"
  ]
}
```

## Eslint Config file

Create `.eslintrc.js` to the project root and add the following:

```
module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true,
  },
  extends: [
    'airbnb',
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:@typescript-eslint/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaFeatures: { jsx: true },
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  plugins: ['react', '@typescript-eslint'],
  rules: {
    'no-continue': 'off',
    'no-mixed-operators': 'off',
    'import/no-cycle': 'off',
    'no-param-reassign': 'off',
    'no-restricted-syntax': 'off',
    'no-await-in-loop': 'off',
    'class-methods-use-this': 'off',
    'import/prefer-default-export': 'off',
    'import/no-named-as-default': 0,
    'no-console': 'off',
    'no-underscore-dangle': 'off',
    camelcase: 'off',
    'react/forbid-prop-types': 'off',
    'import/no-unresolved': 'off',
    'no-unused-vars': [
      'error',
      {
        args: 'none',
        ignoreRestSiblings: true,
        varsIgnorePattern: '^_$',
      },
    ],
    'no-unused-expressions': 'off',
    'react/jsx-props-no-spreading': 'off',
    'react/no-did-update-set-state': 'warn',
    'import/extensions': 'off',
    '@typescript-eslint/ban-ts-comment': 'warn',
    '@typescript-eslint/camelcase': 'off',
    '@typescript-eslint/no-namespace': 'off',
    'react/jsx-filename-extension': [1, { extensions: ['.jsx', '.tsx'] }],
    '@typescript-eslint/no-empty-function': 'off',
    'react/require-default-props': 'off',
    '@typescript-eslint/explicit-function-return-type': 'off',
    'jsx-a11y/anchor-is-valid': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    'import/no-extraneous-dependencies': 'off',
    '@typescript-eslint/interface-name-prefix': 'off',
    '@typescript-eslint/no-var-requires': 1,
    'react/react-in-jsx-scope': 'off',
    'object-curly-newline': ['error', { multiline: true, minProperties: 3 }],
    'array-element-newline': [
      'error',
      {
        ArrayExpression: 'consistent',
        ArrayPattern: { minItems: 3 },
      },
    ],
    'sort-imports': [
      'error',
      {
        ignoreCase: false,
        ignoreDeclarationSort: true,
        ignoreMemberSort: false,
        memberSyntaxSortOrder: ['none', 'all', 'single', 'multiple'],
      },
    ],
    "no-plusplus": ["error", { "allowForLoopAfterthoughts": true }],
    noPropertyAccessFromIndexSignature: 0,
    'jsx-a11y/label-has-associated-control': [
      'error',
      { required: { some: ['nesting', 'id'] } },
    ],
    'jsx-a11y/label-has-for': [
      'error',
      { required: { some: ['nesting', 'id'] } },
    ],
    'react/function-component-definition': [
      2,
      {
        namedComponents: ['arrow-function', 'function-declaration'],
        unnamedComponents: 'arrow-function',
      },
    ],
    'eol-last': 1,
    'max-len': ['error', {
      code: 170,
      ignoreComments: true,
      ignoreUrls: true,
    }],
  },
};
```

Create a file named: `.eslintignore` and add: `**/node_modules/**`

## Style Rules (Optional)

### Pre-requisits

- `stylelint`
- `stylelint-config-prettier`
- `stylelint-config-rational-order`
- `stylelint-config-standard`
- `stylelint-declaration-block-no-ignored-properties`
- `stylelint-order`

To install these: `stylelint stylelint-config-prettier stylelint-config-rational-order stylelint-config-standard stylelint-declaration-block-no-ignored-properties stylelint-order`

Create a file named: `.stylelintrc.json` and add:

```
{
  "extends": [
    "stylelint-config-standard",
    "stylelint-config-rational-order",
    "stylelint-config-prettier"
  ],
  "customSyntax": "postcss-less",
  "plugins": ["stylelint-declaration-block-no-ignored-properties"],
  "rules": {
    "function-name-case": ["lower", { "ignoreFunctions": ["/colorPalette/"] }],
    "function-no-unknown": [
      true,
      {
        "ignoreFunctions": [
          "fade",
          "fadeout",
          "tint",
          "darken",
          "ceil",
          "fadein",
          "floor",
          "unit",
          "shade",
          "lighten",
          "percentage",
          "-",
          "~`colorPalette"
        ]
      }
    ],
    "no-descending-specificity": null,
    "no-invalid-position-at-import-rule": null,
    "declaration-empty-line-before": null,
    "keyframes-name-pattern": null,
    "custom-property-pattern": null,
    "number-max-precision": 8,
    "alpha-value-notation": "number",
    "color-function-notation": "legacy",
    "selector-class-pattern": null,
    "selector-id-pattern": null,
    "selector-not-notation": null,
    "indentation": 2
  }
}
```
