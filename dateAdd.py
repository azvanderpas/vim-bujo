import sys
import datetime

start = datetime.date.fromisoformat(sys.argv[1])
end = start + datetime.timedelta(days=int(sys.argv[2]))

print("{:02d}/{:02d}/{:04d}".format(end.month, end.day, end.year), end='')

