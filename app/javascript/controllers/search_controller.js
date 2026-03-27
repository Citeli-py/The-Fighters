import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "empty"]

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    const items = this.listTarget.querySelectorAll("[data-nome]")
    let visibleCount = 0

    items.forEach(item => {
      const nome = item.dataset.nome
      const visible = nome.includes(query)
      item.style.display = visible ? "" : "none"
      if (visible) visibleCount++
    })

    if (this.hasEmptyTarget) {
      this.emptyTarget.style.display = visibleCount === 0 ? "" : "none"
    }
  }
}
