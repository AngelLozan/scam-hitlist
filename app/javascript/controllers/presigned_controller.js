import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
    static targets = ["form", "fileInput"]

    connect() {
        console.log("Controller connected");
        // console.log(this.fileInputTarget);
        // console.log(this.formTarget);
    }

    async fetchPresigned() {
      try {
        const res = await fetch('/presigned');
        const data = await res.json();
        console.log("The url is:", data);
        this.uploadFormTarget.action = data.presigned_url;
      } catch(e) {
        console.log(e);
      }
    }

    handleSubmit(event) {
        event.preventDefault();

        const formData = new FormData(this.formTarget);
        formData.delete('file');

        fetch('/iocs', {
                method: 'POST',
                headers: { "Accept": "text/plain" },
                body: formData,
            })
            .then((response) => {
                if (response.ok) {
                    response.text();
                } else {
                    console.log("Something is wrong with submission");
                }
            })
            .then((data) => {
                console.log(data)
            })
            .catch((error) => {
                console.error(error);
            });
    }

}