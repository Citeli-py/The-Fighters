import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: { type: Number, default: 4000 } }

  connect() {
    this.timer = setTimeout(() => this.dismiss(), this.durationValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    this.element.classList.add("hiding")
    this.element.addEventListener("animationend", () => this.element.remove(), { once: true })
  }
}
