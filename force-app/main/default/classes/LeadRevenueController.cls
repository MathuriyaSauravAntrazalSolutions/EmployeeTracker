/*
*********************************************************
*  @Class Name    :    LeadRevenueController 
*  @Author         :   <Saurav Mathuriya>(saurav.mathuriya@antrazal.com)
*  @Company        :   Antrazal
*  @Date           :   24-05-2024
*  @description    :   Used In Revenue Generated Weekly/Monthly/Quarterly Dashboard
*********************************************************
*/
public with sharing class LeadRevenueController {
    
    /*
    *********************************************************
    *  @Class Name    :    LeadRevenueController 
    *  @Author         :   <Saurav Mathuriya>(saurav.mathuriya@antrazal.com)
    *  @Company        :   Antrazal
    *  @Date           :   24-05-2024
    *  @description    :   Used In Revenue Generated Weekly/Monthly/Quarterly Dashboard
    *********************************************************
    */
    public class CustomObj{
        @AuraEnabled public Integer year{get; set;}
        @AuraEnabled public Integer quarter{get; set;}
        @AuraEnabled public String month{get; set;}
        @AuraEnabled public String week{get; set;}
        @AuraEnabled public Double totalRevenue{get; set;}

        public CustomObj(Integer y, Integer q, String m, String w, Double r){
            this.year = y;
            this.quarter = q;
            this.month = m;
            this.week = w;
            this.totalRevenue = r;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Date getStartDateOfWeek(Integer year, Integer month, Integer week) {
        // Find the first day of the month
        Date firstDayOfMonth = Date.newInstance(year, month, 1);
        
        // Calculate the day of the week for the first day of the month
        Integer dayOfWeekFirstDay = firstDayOfMonth.toStartOfWeek().day();
        
        // Calculate the start date of the first week of the month
        Date startDateFirstWeek = firstDayOfMonth.addDays(1 - dayOfWeekFirstDay);
        
        // Calculate the start date of the given week
        Date startDateOfGivenWeek = startDateFirstWeek.addDays((week - 1) * 7);
        
        // Ensure the start date is within the given month
        if (startDateOfGivenWeek.month() != month) {
            startDateOfGivenWeek = Date.newInstance(year, month, 1);
            startDateOfGivenWeek = startDateOfGivenWeek.toStartOfWeek().addDays((week - 1) * 7);
        }
        
        return startDateOfGivenWeek;
    }

    // New getEndDateOfWeek method
    @AuraEnabled(cacheable=true)
    public static Date getEndDateOfWeek(Integer year, Integer month, Integer week) {
        // Get the start date of the week
        Date startDateOfWeek = getStartDateOfWeek(year, month, week);
        
        // Calculate the end date of the week (6 days after the start date)
        Date endDateOfWeek = startDateOfWeek.addDays(6);
        
        // Ensure the end date is within the given month
        if (endDateOfWeek.month() != month) {
            // If end date goes to the next month, set it to the last day of the given month
            endDateOfWeek = startDateOfWeek.addDays(0);
            while (endDateOfWeek.month() == month) {
                endDateOfWeek = endDateOfWeek.addDays(1);
            }
            endDateOfWeek = endDateOfWeek.addDays(-1);
        }
        
        return endDateOfWeek;
    }

    @AuraEnabled(cacheable=true)
    public static String getMonthName(Integer monthNumber) {
        // Array of month names
        List<String> monthNames = new List<String>{
            'January', 'February', 'March', 'April', 'May', 'June', 
            'July', 'August', 'September', 'October', 'November', 'December'
        };
        
        // Validate the month number
        if (monthNumber < 1 || monthNumber > 12) {
            throw new IllegalArgumentException('Invalid month number: ' + monthNumber);
        }
        
        // Return the month name corresponding to the month number
        return monthNames[monthNumber - 1];
    }


    // Method to format the date range
    @AuraEnabled(cacheable=true)
    public static String formatDateRange(Date startDate, Date endDate) {
        String startD = startDate.format();
        String endD = endDate.format();
        return startD + ' to ' + endD;
    }



    @AuraEnabled(cacheable=true)
    public static List<CustomObj> getMonthlyRevenue() {
        AggregateResult[] groupedResults = [
            SELECT 
                CALENDAR_YEAR(CreatedDate) Year, 
                CALENDAR_MONTH(CreatedDate) Month, 
                SUM(AnnualRevenue) TotalRevenue
            FROM 
                Lead
            WHERE 
                CreatedDate != NULL
            GROUP BY 
                CALENDAR_YEAR(CreatedDate), 
                CALENDAR_MONTH(CreatedDate)
            ORDER BY 
                CALENDAR_YEAR(CreatedDate), 
                CALENDAR_MONTH(CreatedDate)
        ];

        List<CustomObj> formattedResults = new List<CustomObj>();

        for(AggregateResult result: groupedResults){
            Integer year = (Integer)result.get('Year');
            Integer month = (Integer)result.get('Month');
            Double totalRevenue = (Double)result.get('TotalRevenue');
            
            String monthName = LeadRevenueController.getMonthName(month);
            CustomObj newObj = new CustomObj(year, -1, monthName, '', totalRevenue);
            formattedResults.add(newObj);
        }
        System.Debug(formattedResults);
        return formattedResults;
    }

    @AuraEnabled(cacheable=true)
    public static List<CustomObj> getQuarterlyRevenue() {
        AggregateResult[] groupedResults = [
            SELECT 
                CALENDAR_YEAR(CreatedDate) Year, 
                Calendar_Quarter(CreatedDate) Quarter, 
                SUM(AnnualRevenue) totalRevenue
            FROM 
                Lead
            WHERE 
                CreatedDate!= NULL
            GROUP BY 
                CALENDAR_YEAR(CreatedDate), 
                Calendar_Quarter(CreatedDate)
            ORDER BY 
                CALENDAR_YEAR(CreatedDate), 
                Calendar_Quarter(CreatedDate)
        ];
        List<CustomObj> formattedResults = new List<CustomObj>();

        for(AggregateResult result: groupedResults){
            Integer year = (Integer)result.get('Year');
            Integer quarter = (Integer)result.get('Quarter');
            Double totalRevenue = (Double)result.get('TotalRevenue');
            
            CustomObj newObj = new CustomObj(year, quarter, '', '', totalRevenue);
            formattedResults.add(newObj);
        }
        System.Debug(formattedResults);
        return formattedResults;
    }

    @AuraEnabled(cacheable=true)
    public static List<CustomObj> getWeeklyRevenue() {
        AggregateResult[] groupedResults = [
            SELECT 
                CALENDAR_YEAR(CreatedDate) Year, 
                CALENDAR_MONTH(CreatedDate) Month, 
                WEEK_IN_MONTH(CreatedDate) Week, 
                SUM(AnnualRevenue) TotalRevenue
            FROM 
                Lead
            WHERE 
                CreatedDate!= NULL
            GROUP BY 
                CALENDAR_YEAR(CreatedDate), 
                CALENDAR_MONTH(CreatedDate), 
                WEEK_IN_MONTH(CreatedDate)
            ORDER BY 
                CALENDAR_YEAR(CreatedDate), 
                CALENDAR_MONTH(CreatedDate), 
                WEEK_IN_MONTH(CreatedDate)
        ];

        List<CustomObj> formattedResults = new List<CustomObj>();

        for(AggregateResult result: groupedResults){
            Integer year = (Integer)result.get('Year');
            Integer month = (Integer)result.get('Month');
            Integer week = (Integer)result.get('Week');
            Double totalRevenue = (Double)result.get('TotalRevenue');
            
            Date startOfWeek = LeadRevenueController.getStartDateOfWeek(year, month, week);
            Date endOfWeek = LeadRevenueController.getEndDateOfWeek(year, month, week);
            String monthName = LeadRevenueController.getMonthName(month);
            String formattedWeekRange = LeadRevenueController.formatDateRange(startOfWeek, endOfWeek);
            CustomObj newObj = new CustomObj(year, -1, monthName, formattedWeekRange, totalRevenue);
            formattedResults.add(newObj);
        }
        System.Debug(formattedResults);
        return formattedResults;
    }
}