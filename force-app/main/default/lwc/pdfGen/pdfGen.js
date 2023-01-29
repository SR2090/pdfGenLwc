import { LightningElement } from 'lwc';
import jsPDF  from '@salesforce/resourceUrl/jsPDF';
import { loadScript } from 'lightning/platformResourceLoader';
import getAccountDetails from '@salesforce/apex/AccountDataController.getAccountDetails';
export default class PdfGen extends LightningElement {
    scriptLoaded;
    data = [];
    columns = [['fieldLabels', 'fieldValues', 'sObjects', 'recordIds']];
    eachRow = [];
    allRows =[];

    renderedCallback(){
        if(this.scriptLoaded){
            return;
        }
        this.scriptLoaded = true;
        loadScript(this, jsPDF + '/jsPDF/jspdf.umd.min.js')
        .then(() => {
            console.log('%cloaded jspdf', 'color: pink;')
            loadScript(this, jsPDF + '/jsPDF/jspdf.plugin.autotable.js').then(() => {
                console.log('%cloaded autotable', 'color: pink;');
            }).catch(error => {
                console.error(error);
            })
        })
        .catch(error => {
            console.error(error);
        });
    }

    handleButtonClick(){
        this.generatePdf();
    }

    generatePdf(){
        getAccountDetails().then((response) => {
            this.data = JSON.parse(JSON.stringify(response));
            let body = [];
            
            
            for(let i = 0 ; i < this.data.length; i++){
                let eachRow = [];
                eachRow.push(this.data[i].fieldLabels);
                eachRow.push(this.data[i].fieldValues);
                eachRow.push(this.data[i].sObjectName);
                eachRow.push(this.data[i].recordIds);
                body.push(eachRow);
            }
            console.log("", body);
            const { jsPDF } = window.jspdf;
            let doc = new jsPDF();
            doc.text("Pdf generation using external js library", 14, 20)
            doc.autoTable({
                head: this.columns,
                body: [[1,2,3,4], [1,2,3,4]],
                startY: 25,
                // // Default for all columns
                // styles: { overflow: 'ellipsize', cellWidth: 'wrap' },
                // // Override the default above for the text column
                // columnStyles: { text: { cellWidth: 'auto' } },
            })
            doc.save('asd.pdf');
        }).catch(error => {
            console.log(error);
        })
    }
}