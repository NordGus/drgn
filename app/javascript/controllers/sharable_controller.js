import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="sharable"
export default class extends Controller {
    static values = {
        content: String
    }

    copy(event) {
        event.preventDefault()

        navigator.clipboard.writeText(this.contentValue).then(() => {
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