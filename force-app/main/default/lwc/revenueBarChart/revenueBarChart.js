import { LightningElement, wire, track } from 'lwc';
import getMonthlyRevenue from '@salesforce/apex/LeadRevenueController.getMonthlyRevenue';
import getQuarterlyRevenue from '@salesforce/apex/LeadRevenueController.getQuarterlyRevenue';
import getWeeklyRevenue from '@salesforce/apex/LeadRevenueController.getWeeklyRevenue';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJs';

export default class RevenueBarChart extends LightningElement {
    @track filter = 'monthly';
    @track filterOptions = [
        { label: 'Quarterly', value: 'quarterly' },
        { label: 'Monthly', value: 'monthly' },
        { label: 'Weekly', value: 'weekly' }
    ];


    handleFilterChange(event) {
        this.filter = event.detail.value;
        if (this.chart) {
            this.updateChartData();
        }
    }


    chart;
    chartjsInitialized = false;
    monthlyRevenue
    quarterlyRevenue
    weeklyRevenue
    @wire(getMonthlyRevenue)
    getMonthRevenue({ data, error }) {
        if (data) {
            this.monthlyRevenue = {data};
        }
    }
    @wire(getQuarterlyRevenue)
    getQuarterRevenue({ data, error }) {
        if (data) {
            this.quarterlyRevenue = {data};
        }
    }

    @wire(getWeeklyRevenue)
    getWeekRevenue({ data, error }) {
        if (data) {
            this.weeklyRevenue = {data};
        }
    }

    renderedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;

        Promise.all([
            loadScript(this, chartjs),
        ])
        .then(() => {
            this.initializeChart();
        })
        .catch(error => {
            console.error('Error loading Chart.js', error);
        });
    }

    initializeChart() {
        const ctx = this.template.querySelector('canvas.chart').getContext('2d');
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: [], // Labels for the X axis
                datasets: [{
                    label: 'Monthly Revenue',
                    data: [],
                    backgroundColor: 'rgba(232, 72, 155, 0.8)',
                    borderColor: 'rgba(93, 12, 54, 0.8)',
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
        setTimeout(()=>{
            this.updateChartData();
        }, 1000);
    }

    updateChartData() {
        if (this.filter==='monthly') {
            this.chart.data.labels = this.monthlyRevenue.data.map(item => `${item.month} ${item.year}`);
            this.chart.data.datasets[0].data = this.monthlyRevenue.data.map(item => item.totalRevenue);
            this.chart.data.datasets[0].label = 'Monthly Revenue';
            this.chart.data.datasets[0].backgroundColor = 'rgba(232, 72, 155, 0.8)';
            this.chart.data.datasets[0].borderColor = 'rgba(93, 12, 54, 0.8)';
        }

        if (this.filter==='quarterly') {
            this.chart.data.labels = this.quarterlyRevenue.data.map(item => `Quarter ${item.quarter} Of ${item.year}`);
            this.chart.data.datasets[0].data = this.quarterlyRevenue.data.map(item => item.totalRevenue);
            this.chart.data.datasets[0].label = 'Quarterly Revenue';
            this.chart.data.datasets[0].backgroundColor = 'rgba(0, 87, 228, 0.8)';
            this.chart.data.datasets[0].borderColor = 'rgba(5, 28, 65, 0.8)';
        }

        if (this.filter==='weekly') {
            this.chart.data.labels = this.weeklyRevenue.data.map(item => `Week ${item.week}`);
            this.chart.data.datasets[0].data = this.weeklyRevenue.data.map(item => item.totalRevenue);
            this.chart.data.datasets[0].label = 'Weekly Revenue';
            this.chart.data.datasets[0].backgroundColor = 'rgba(248, 248, 0, 0.8)';
            this.chart.data.datasets[0].borderColor = 'rgba(31, 31, 10, 0.8)';
        }
        this.chart.update();
    }
}