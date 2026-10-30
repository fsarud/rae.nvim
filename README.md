# rae.nvim

Consulta el Diccionario de la Real Academia Española desde Neovim.

> **Aviso:** `rae.nvim` es un proyecto **no oficial**, no afiliado ni respaldado por la Real Academia Española. Los datos provienen de [rae-api.com](https://rae-api.com), un servicio no oficial con acceso gratuito para uso personal.

## Características

- **`:RAEDef`** — muestra la definición completa de la palabra bajo el cursor (etimología, acepciones y locuciones) en un buffer flotante o en un split.
- **`:RAESin`** — abre un picker de Telescope con los sinónimos y antónimos de la palabra bajo el cursor. Se puede hacer fuzzy search y `<CR>` reemplaza la palabra en el buffer con la elegida.
- Funciona en modo visual: si selecciona el comienzo de una palabra consulta esa forma exacta. Útil para plurales y conjugaciones que la RAE no indexa (ej. `normas` no tiene sinónimos, pero `norma` sí).
- Tres modos de visualización para la definición: flotante pegado al cursor, flotante abajo, o split tradicional.
- Normalización NFC automática: las tildes escritas como caracteres combinados (típico en macOS) funcionan igual.
- Manejo de errores claro: palabra inexistente, API key inválida, límite de consultas.

## Requisitos

- Neovim ≥ 0.10
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- Una API key gratuita de [rae-api.com](https://rae-api.com) (5000 consultas/día). La key es opcional: sin ella, la API permite 10 req/min y 100 req/día.
- Requiere `curl` en el PATH (para consultar la API).

## Instalación

### lazy.nvim (LazyVim)

```lua
return {
  {
    "fsarud/rae.nvim",
    name = "rae.nvim",
    main = "rae",
    lazy = false,
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      -- api_key = "rae_live_...",  -- o exporte RAE_API_KEY
      -- display = "float_cursor",  -- "float_cursor" | "float_bottom" | "split"
      mappings = false, -- los mappings se definen abajo, en `keys`
    },
    keys = {
      { "<leader>rd", "<cmd>RAEDef<cr>", desc = "RAE: definición", mode = "n" },
      { "<leader>rs", "<cmd>RAESin<cr>", desc = "RAE: sinónimos/antónimos", mode = "n" },
      { "<leader>rd", ":'<,'>RAEDef<cr>", desc = "RAE: definición (visual)", mode = "v" },
      { "<leader>rs", ":'<,'>RAESin<cr>", desc = "RAE: sinónimos (visual)", mode = "v" },
    },
  },
  -- Opcional: agrega título al grupo de binds en which-key
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>r", group = "Diccionario RAE", icon = "📖" },
      },
    },
  },
}
```

(Si define los mappings en `keys` de lazy (como en el ejemplo), ponga `mappings = false` en `opts` para evitar duplicarlos).

### Configuración

```lua
require("rae").setup({
  -- API key. Si es nil, se usa vim.env.RAE_API_KEY.
  -- Regístrese gratis en https://rae-api.com para obtener la suya.
  api_key = nil,

  -- Modo de visualización de la definición:
  --   "float_cursor" → flotante pegado al cursor (se cierra al salir de la palabra)
  --   "float_bottom" → flotante abajo, centrado (se cierra al salir de la palabra)
  --   "split"        → split horizontal inferior (se cierra con q)
  display = "float_cursor",

  -- mappings = false, 
  -- Mappings por defecto. Ponga false para no crear ninguno
  -- (por ejemplo, si los define en `keys` de lazy.nvim).
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

Si no quiere hardcodear su API key en su config (si comparte dotfiles), puede usar una variable de entorno:

```sh
# ~/.zshrc, ~/.bashrc, etc.
export RAE_API_KEY="rae_live_..."
```

(Si prefiere configurarla directamente en Lua, setup({ api_key = "..." }) funciona, pero tenga en cuenta que el archivo queda en texto plano).

### Uso

Ponga el cursor en modo normal sobre una palabra y:

| Comando   | Mapping por defecto | Modo    | Acción |
|-----------|---------------------|---------|--------|
| `:RAEDef` | `<leader>rd`        | Normal  | Muestra la definición completa en un flotante o split |
| `:RAEDef` | `<leader>rd`        | Visual  | Muestra la definición de la selección |
| `:RAESin` | `<leader>rs`        | Normal  | Abre el picker de sinónimos/antónimos |
| `:RAESin` | `<leader>rs`        | Visual  | Abre el picker para la selección; `<CR>` la reemplaza |

También puede pasar la palabra buscada como argumento:

```vim
:RAEDef alegoría
:RAESin casa
```

En el picker de sinónimos:

- Escriba para filtrar (fuzzy sobre la palabra).
- `<CR>` reemplaza la palabra original en el buffer con la elegida.
- `<Esc>` o q cierra sin cambios.

En el flotante de definición:

- `q` cierra la ventana.
- El buffer es de solo lectura y markdown: puede hacer `gf`, buscar, etc.

### Limitaciones conocidas

- No hay caché implementado: cada consulta va a la API.
- El flotante se cierra al mover el cursor fuera de la palabra. Si le molesta, pruebe cambiar a display = "split".
- No se muestran sinónimos/antónimos de locuciones (solo de las acepciones principales).

### Créditos

- Datos: rae-api.com, API no oficial.
- Diccionario: Real Academia Española.
- UI: telescope.nvim.

### Licencia

El código de este plugin está bajo MIT. Los datos devueltos por rae-api.com pertenecen a sus respectivos titulares y están sujetos a los términos de ese servicio.
