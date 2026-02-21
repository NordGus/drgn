import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirmation-form"
export default class extends Controller {
  static targets = ["dialog", "password"]

  connect() {
    if (this.element.tagName.toLowerCase() !== "form") throw new Error("ConfirmationFormController must be applied to a form element")
    if (!this.dialogTarget) throw new Error("ConfirmationFormController requires a dialog target")
    if (!this.passwordTarget) throw new Error("ConfirmationFormController requires a password target")

    this.passwordTarget.value = undefined

    this.element.addEventListener("keypress", this.preventSubmitOnEnter.bind(this))
    this.element.addEventListener("keydown", this.preventSubmitOnEnter.bind(this))
    this.element.addEventListener("keyup", this.preventSubmitOnEnter.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("keypress", this.preventSubmitOnEnter.bind(this))
    this.element.removeEventListener("keydown", this.preventSubmitOnEnter.bind(this))
    this.element.removeEventListener("keyup", this.preventSubmitOnEnter.bind(this))
  }

  preventSubmitOnEnter(event) {
    if (event.key !== "Enter") return

    const target = event.target.tagName.toLowerCase()

    if (target === "textarea" || target === "submit") return

    this.dialogTarget.showModal()
    event.preventDefault()
  }

  openConfirm(_event) {
    this.passwordTarget.value = null
  }

  onSubmit() {
    this.dialogTarget.close()
  }
}
