import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="sharable"
export default class extends Controller {
    static targets = ["input"]
    static values = {
        urlPath: String
    }

    connect() {
        this.inputTarget.value = window.location.origin + this.urlPathValue
    }

    copy(event) {
        event.preventDefault()
        const url = this.inputTarget.value

        navigator.clipboard.writeText(url).then(() => {
            const originalText = event.target.innerText
            event.target.innerText = "Copied!"
            setTimeout(() => {
                event.target.innerText = originalText
            }, 2000)
        }).catch(err => {
            console.error("Failed to copy: ", err)
        })
    }
}