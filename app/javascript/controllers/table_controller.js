import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="table"
export default class extends Controller {
  static targets = ['tableRow', 'searchForm', 'input', 'url']

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

  openAll(e) {
    e.preventDefault();
    console.log('clicked open all');
    this.urlTargets.forEach((element) => {
      // console.log(element.innerText);
      window.open(`${element.innerText}`, "_blank")
    })
  }

  async copyTelegram(e){
    e.preventDefault();
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
