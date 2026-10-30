# rae.nvim
<<<<<<< HEAD
Un plugin de neovim para consultar definiciones de la RAE vía rae-api.com. No es información oficial de la RAE ni está afiliado a esta institución de ninguna forma.
=======

Consulta el Diccionario de la Lengua Española desde Neovim, sin salir del editor.

> **Aviso:** `rae.nvim` es un proyecto **no oficial**, no afiliado ni respaldado por la Real Academia Española. Los datos provienen de [rae-api.com](https://rae-api.com), un servicio no oficial. Usalo bajo tu responsabilidad y respetá los límites del servicio.

## Características

- **`:RAEDef`** — muestra la definición completa de la palabra bajo el cursor (etimología, acepciones y locuciones) en un buffer flotante o en un split.
- **`:RAESin`** — abre un picker (Telescope) con los sinónimos y antónimos de la palabra bajo el cursor. `<CR>` reemplaza la palabra en el buffer con la elegida.
- Tres modos de visualización para la definición: flotante pegado al cursor, flotante abajo, o split tradicional.
- Normalización NFC automática: las tildes escritas como caracteres combinados (típico en macOS) funcionan igual.
- Manejo de errores claro: palabra inexistente, API key inválida, límite de consultas.

## Requisitos

- Neovim ≥ 0.9
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- Una API key gratuita de [rae-api.com](https://rae-api.com) (5000 consultas/día). La key es opcional: sin ella, la API permite 10 req/min y 100 req/día.

## Instalación

### lazy.nvim (LazyVim)

```lua
{
  "tu-usuario/rae.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  opts = {
    -- api_key = "rae_live_...",  -- o exportá RAE_API_KEY en tu shell
    -- display = "float_cursor",  -- "float_cursor" | "float_bottom" | "split"
  },
  keys = {
    { "<leader>rd", "<cmd>RAEDef<cr>", desc = "RAE: definición" },
    { "<leader>rs", "<cmd>RAESin<cr>", desc = "RAE: sinónimos/antónimos" },
  },
}
```

### packer.nvim

```lua
use {
  "tu-usuario/rae.nvim",
  requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  config = function()
    require("rae").setup({})
  end,
}
```

### Configuración

```lua
require("rae").setup({
  -- API key. Si es nil, se usa vim.env.RAE_API_KEY.
  -- Registrate gratis en https://rae-api.com para obtener la tuya.
  api_key = nil,

  -- Modo de visualización de la definición:
  --   "float_cursor" → flotante pegado al cursor (se cierra al salir de la palabra)
  --   "float_bottom" → flotante abajo, centrado (se cierra al salir de la palabra)
  --   "split"        → split horizontal inferior (se cierra con q)
  display = "float_cursor",

  -- Mappings por defecto. Poné false para no crear ninguno.
  -- mappings = false,
  mappings = {
    definition = "<leader>rd",
    synonyms   = "<leader>rs",
  },

  -- Reservado para futuras versiones.
  cache = {
    enabled = true,
    ttl = 86400, -- 24 h
  },
})
```

### API key

No hardcodees la key en tu config si compartís el dotfiles. Preferí una variable de entorno:

```sh
# ~/.zshrc, ~/.bashrc, etc.
export RAE_API_KEY="rae_live_..."
```

Si preferís configurarla en Lua, setup({ api_key = "..." }) funciona, pero tené en cuenta que el archivo queda en texto plano.

### Uso

Poné el cursor sobre una palabra y:
Comando Mapping por defecto Acción
:RAEDef <leader>rd Muestra la definición completa
:RAESin <leader>rs Abre el picker de sinónimos/antónimos

También podés pasar la palabra como argumento:

```vim
:RAEDef alegoría
:RAESin casa
```

En el picker de sinónimos:

- Escribí para filtrar (fuzzy finding sobre la palabra).
- <CR> reemplaza la palabra original en el buffer con la elegida.
- <Esc> o q cierra sin cambios.

En el flotante de definición:

- q cierra la ventana.
- El buffer es de solo lectura y markdown: podés hacer gf, buscar, etc.

### Limitaciones conocidas

- Sin caché todavía: cada consulta golpea la API. Si consultás mucho, considerá exportar RAE_API_KEY para tener 5000 req/día.
- El flotante se cierra al mover el cursor fuera de la palabra. Si te molesta, cambiá display = "split".
- No se muestran sinónimos/antónimos de locuciones (solo de las acepciones principales).

### Créditos

- Datos: rae-api.com, API no oficial.
- Diccionario: Real Academia Española.
- UI: telescope.nvim.

### Licencia

MIT. Ver LICENSE.

El código de este plugin está bajo MIT. Los datos devueltos por rae-api.com pertenecen a sus respectivos titulares y están sujetos a los términos de ese servicio.
>>>>>>> 2be1e81 (Primer commit)
