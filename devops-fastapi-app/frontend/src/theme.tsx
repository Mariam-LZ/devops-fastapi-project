import { createSystem, defaultConfig } from "@chakra-ui/react"
import { buttonRecipe } from "./theme/button.recipe"

export const system = createSystem(defaultConfig, {
  globalCss: {
    html: {
      fontSize: "16px",
    },
    body: {
      fontSize: "0.875rem",
      margin: 0,
      padding: 0,
    },
    ".main-link": {
      color: "ui.main",
      fontWeight: "bold",
    },
  },
  theme: {
    tokens: {
      colors: {
        brand: {
          50: { value: "#f2eeff" },
          100: { value: "#e0d8ff" },
          200: { value: "#c3b4ff" },
          300: { value: "#a390f5" },
          400: { value: "#816be6" },
          500: { value: "#5D3FD3" },
          600: { value: "#4F35B3" },
          700: { value: "#422c94" },
          800: { value: "#342375" },
          900: { value: "#261a57" },
          950: { value: "#171038" },
        },
        ui: {
          main: { value: "#5D3FD3" },
        },
      },
    },
    semanticTokens: {
      colors: {
        brand: {
          contrast: { value: "#ffffff" },
          fg: { value: "{colors.brand.700}" },
          subtle: { value: "{colors.brand.100}" },
          muted: { value: "{colors.brand.200}" },
          emphasized: { value: "{colors.brand.300}" },
          solid: { value: "{colors.brand.500}" },
          focusRing: { value: "{colors.brand.500}" },
        },
      },
    },
    recipes: {
      button: buttonRecipe,
    },
  },
})
