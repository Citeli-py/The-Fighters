// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { Turbo } from "@hotwired/turbo-rails"

Turbo.config.forms.confirm = (message, element, submitter) => {
  return new Promise((resolve) => {
    document.dispatchEvent(new CustomEvent("confirm:open", {
      bubbles: true,
      detail: { message, element, resolve }
    }))
  })
}
