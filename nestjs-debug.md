# Setup Debugging in nestjs
Create a file named `launch.json` in the `.vscode` direcotory and paste the following:

```
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch NestJS",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "start:debug"],
      "skipFiles": ["<node_internals>/**"],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen"
    },
    {
      "type": "node",
      "request": "attach",
      "name": "Attach NestJS",
      "port": 9229,
      "restart": true,
      "skipFiles": ["<node_internals>/**"]
    }
  ]
}
```
Now press `F5` for debugging.

> This setup needs a debug script to be present in `package.json` named `start:debug`. In this case the script is: `"start:debug": "nest start --debug --watch"`
