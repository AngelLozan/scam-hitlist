import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
    static targets = ["form", "fileInput", "fileUrl"]

    connect() {
        console.log("Controller connected");
        // console.log(this.fileInputTarget);
        console.log(this.formTarget);
        console.log(this.fileUrlTarget);
    }

    async fetchPresigned() {
        try {
            const res = await fetch('/presigned');
            const data = await res.json();
            console.log("The url is:", data);
            this.fileUrlTarget.setAttribute("data-url", data.presigned_url);
            // return(data.presigned_url);
        } catch (e) {
            console.log(e);
        }
    }

    handleSubmit(event) {
        event.preventDefault();
        const path = this.formTarget.action
        const upload_file_url = this.fileUrlTarget.getAttribute("data-url");

        this.fileUrlTarget.value = upload_file_url
        const formData = new FormData(this.formTarget);

        formData.set('file_url', upload_file_url);


        fetch(path, {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then((data) => {
                if (data.show_url) {
                    window.location.href = data.show_url;
                } else {
                    console.log("Data:", data);
                }
            })
            .catch((error) => {
                console.error(error);
            });
    }

}