import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="settings"
export default class extends Controller {
  static targets = [ "link" ]
  static values = {
    currentController: String
  }

  linkTargetConnected(target) {
    if (target.dataset.panelController === this.currentControllerValue) {
      target.classList.toggle("active", true);
    }
  }
}
