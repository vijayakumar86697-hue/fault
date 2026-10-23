package com.campus.util;

import java.sql.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 * Utility for date formatting and relative time humanization.
 */
public class DateUtil {
    private static final String DATE_TIME_FORMAT = "dd MMM yyyy, hh:mm a";
    private static final String DATE_FORMAT = "dd MMM yyyy";

    private DateUtil() {}

    public static String formatDateTime(Timestamp timestamp) {
        if (timestamp == null) return "N/A";
        return new SimpleDateFormat(DATE_TIME_FORMAT).format(timestamp);
    }

    public static String formatDate(Date date) {
        if (date == null) return "N/A";
        return new SimpleDateFormat(DATE_FORMAT).format(date);
    }

    public static String timeAgo(Timestamp timestamp) {
        if (timestamp == null) return "";
        long diffMs = System.currentTimeMillis() - timestamp.getTime();
        long diffSec = diffMs / 1000;
        if (diffSec < 60) return "Just now";
        long diffMin = diffSec / 60;
        if (diffMin < 60) return diffMin + " min" + (diffMin > 1 ? "s" : "") + " ago";
        long diffHour = diffMin / 60;
        if (diffHour < 24) return diffHour + " hour" + (diffHour > 1 ? "s" : "") + " ago";
        long diffDay = diffHour / 24;
        if (diffDay < 30) return diffDay + " day" + (diffDay > 1 ? "s" : "") + " ago";
        long diffMonth = diffDay / 30;
        return diffMonth + " month" + (diffMonth > 1 ? "s" : "") + " ago";
    }
}
