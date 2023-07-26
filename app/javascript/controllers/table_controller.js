import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="table"
export default class extends Controller {
  static targets = ['tableRow', 'searchForm', 'input', 'url', 'snackbar']

  connect() {
    console.log('table connected');

  }

  showIoc(e) {
    e.preventDefault();
    console.log('clicked ioc')
    const url = e.currentTarget.getAttribute('data-url');
    window.location.href = url;
  }

  showForm(e) {
    e.preventDefault();
    console.log('clicked form')
    const url = e.currentTarget.getAttribute('data-url');
    window.location.href = url;
  }

  showHost(e) {
    e.preventDefault();
    console.log('clicked host')
    const url = e.currentTarget.getAttribute('data-url');
    window.location.href = url;
  }

  resetSearch(e) {
    e.preventDefault();
    this.searchFormTarget.reset();
    this.inputTarget.value = '';
    this.searchFormTarget.submit();
  }

  // async openAll(e) {
  //   e.preventDefault();
  //   console.log('clicked open all');
  //   for (let i = 0; i < this.urlTargets.length; i++) {
  //     const element = await this.urlTargets[i].innerText;
  //     await window.open(element, "_blank", "noopener");
  //     console.log(`Opened ${element}`);
  //   }
  //   // this.urlTargets.forEach((element) => {
  //   //   // console.log(element.innerText);
  //   //   window.open(`${element.innerText}`, "_blank")
  //   // })
  // }

  async openAll(e) {
    e.preventDefault();
    console.log('clicked open all');
    for (let i = 0; i < this.urlTargets.length; i++) {
      const element = await this.urlTargets[i].innerText;
      setTimeout(() => {
        window.open(element, "_blank", "noopener");
      }, i * 1000);
      console.log(`Opened ${element}`);
    }
  }

  async copyTelegram(e){
    e.preventDefault();
    this.snackbarTarget.className = "show";
    setTimeout(() => {
      this.snackbarTarget.className = this.snackbarTarget.className.replace("show", "");
    }, 2000);
    const tgUrls = [];
    try {
      this.urlTargets.forEach((el) => {
        if (el.innerText.includes('t.me')) {
          tgUrls.push(`${el.innerText} \n`)
        }
      })

      const tgText = tgUrls.join('');
      await navigator.clipboard.writeText(tgText)

    } catch (error) {
      console.log(error.message);
    }
  }



  get searchFormTarget() {
    return this.targets.find('searchForm');
  }
}
