import sys
import datetime
import re

def addMonths(date, num):
    try:
        return datetime.date.fromisoformat(
                    str(int(date.year + (date.month + intervalMult-1)/12)) + "-" +
                    "{:02d}".format((date.month + intervalMult-1) % 12 + 1) + "-" +
                    "{:02d}".format(date.day))
    except ValueError:
        return datetime.date.fromisoformat(
                    str(int(date.year + (date.month + intervalMult-1)/12)) + "-" +
                    "{:02d}".format(((date.month + intervalMult) % 12 + 1)) + "-01") - datetime.timedelta(days=1)


# Parse Habits.md
habitsFile = open("Habits.md")
for line in habitsFile:
    # Check for comment lines
    if not line.lstrip().startswith("#"):
        # StartDate <every $1 days/weeks/months/years> EndDate  TodoItem
        # %m/%d/%Y  (\d\+)\?([dwmy])                   %m/%d/%Y (.*)
        vals = re.match(r"(\d+/\d+/\d+)\s+(\d*[dwmy])\s+(\d+/\d+/\d+)\s+(.*)", line.strip())
        if vals:
            startStrs = vals.group(1).split('/')
            start = datetime.date(int(startStrs[2]),int(startStrs[0]), int(startStrs[1]))
            intervalBase = vals.group(2)[-1]
            intervalMult = int(vals.group(2)[0:-1]) if len(vals.group(2)) > 1 else 1
            if intervalBase == 'd':
                intervalAdd = lambda date : date + datetime.timedelta(days=intervalMult)
            elif intervalBase == 'w':
                intervalAdd = lambda date : date + datetime.timedelta(days=7*intervalMult)
            elif intervalBase == 'm':
                intervalAdd = lambda date : addMonths(date, intervalMult)
            elif intervalBase == 'y':
                intervalAdd = lambda date : datetime.date.fromisoformat(
                                                str(date.year + intervalMult) + "-" +
                                                "{:02d}".format(date.month) + "-" +
                                                "{:02d}".format(date.day))
            endStrs = vals.group(3).split('/')
            end = datetime.date(int(endStrs[2]),int(endStrs[0]), int(endStrs[1]))
            task = vals.group(4)

            testDate = start
            today = datetime.date.today()
            while end >= testDate and start <= testDate:
                if  today == testDate:
                    print("  " + task)
                    break
                testDate = intervalAdd(testDate)








