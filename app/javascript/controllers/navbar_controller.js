import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = ['format', 'snackbar']

  connect() {
    console.log("Navbar controller connected");
  };

  async formatURL(e) {
    e.preventDefault();
    const url = this.formatTarget.value
    let formatted;
    if (url.includes('[.]')) {
      formatted = await url.replace(/[\][\]']+/g,'');
    } else {
      formatted = await url.replaceAll('.', '[.]')
    }
    this.formatTarget.value = formatted;
    await navigator.clipboard.writeText(formatted);
    this.snackbarTarget.className = "show";
    setTimeout(() => {
      this.snackbarTarget.className = this.snackbarTarget.className.replace("show", "");
      this.formatTarget.value = "";
    }, 2000);
  };


}
