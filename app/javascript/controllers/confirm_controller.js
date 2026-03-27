import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "confirmBtn"]

  connect() {
    document.addEventListener("confirm:open", this.handleOpen)
  }

  disconnect() {
    document.removeEventListener("confirm:open", this.handleOpen)
  }

  handleOpen = ({ detail: { message, element, resolve } }) => {
    this.resolve = resolve
    this.messageTarget.textContent = message

    const form = (element instanceof HTMLFormElement) ? element : element?.closest?.("form")
    const method = (
      form?.querySelector("input[name='_method']")?.value ||
      form?.method ||
      element?.dataset?.turboMethod ||
      ""
    ).toLowerCase()
    const isDanger = method === "delete"

    this.confirmBtnTarget.className = `btn ${isDanger ? "btn-danger" : "btn-primary"}`
    this.element.classList.add("modal--open")
    this.confirmBtnTarget.focus()
  }

  confirm() {
    this.resolve?.(true)
    this._close()
  }

  cancel() {
    this.resolve?.(false)
    this._close()
  }

  backdropClick(event) {
    if (event.target === event.currentTarget) {
      this.cancel()
    }
  }

  keydown(event) {
    if (event.key === "Escape" && this.element.classList.contains("modal--open")) {
      this.cancel()
    }
  }

  _close() {
    this.element.classList.remove("modal--open")
    this.resolve = null
  }
}
