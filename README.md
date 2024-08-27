# CSharp to Typescript Interface

This is an experimental project to generate a Typescript interface from CSharp. I use it personally to generate types for my C# projects. This will be updated based on my needs and expect breaking changes.
If you have any suggestions, please open an issue or a PR.

## Installation 
### Lazy
I use [lazy.nvim](https://github.com/folke/lazy.nvim) to load this plugin.
```lua
return {
  dir = 'markchristianlacap/cs-to-ts.nvim',
  ft = 'cs',
  event = 'InsertEnter',
  keys = {
    {
      '<leader>lc',
      mode = { 'v', 'n' },
      function()
        --get yanked text
        local text = vim.fn.getreg '"'
        -- convert
        local interface = require('cs-to-ts').convert(text)
        if interface then
          --put to vim register
          vim.fn.setreg('"', interface)
        end
      end,
      desc = 'Convert yanked C# to TypeScript interface',
    },
  },
}
```
