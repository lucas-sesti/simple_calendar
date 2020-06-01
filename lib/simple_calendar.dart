library simple_calendar;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_calendar/core/models/simple-header-calendar.model.dart';

class SimpleCalendar extends StatefulWidget {
  final DateTime initialDate;
  final bool showDays;
  final Function(DateTime actualDate) onTapMonthHeader;
  final Function(DateTime date) onChangeDate;
  final Function(DateTime selectedDate, List<dynamic> events) onSelectDate;
  final BuildContext ctx;
  final Map<DateTime, Map<Color, List<dynamic>>> events;
  final Function dayBuilder;
  final bool showOutsideDays;

  final SimpleHeaderCalendarStyle headerStyle;

  SimpleCalendar({
    @required this.headerStyle,
    this.showDays = true,
    this.onSelectDate,
    this.onChangeDate,
    this.ctx,
    this.initialDate,
    this.onTapMonthHeader,
    this.events,
    this.dayBuilder,
    this.showOutsideDays = true,
  });

  @override
  _SimpleCalendarState createState() => _SimpleCalendarState();
}

class _SimpleCalendarState extends State<SimpleCalendar> {
  final int _daysInWeek = 7;

  List<Widget> tableRows = [];
  List<Widget> tableCells = [];
  DateTime actualDate = DateTime.now();
  DateTime selectedDate;
  List<List> weeks = [];

  @override
  void initState() {
    super.initState();
    if (!mounted) return;

    if (widget.initialDate != null) {
      setState(() {
        actualDate = widget.initialDate;
        selectedDate = widget.initialDate;
      });
    }

    if (widget.showDays) {
      _createWeeks();
    }
  }

  String _getDayOfWeek(DateTime date) {
    return DateFormat(
      'EEE',
    ).format(date);
  }

  List _weekEqualizer(List<List> weeks) {
    List valuesToAdd = [];
    weeks.asMap().map((index, value) {
      if (index < weeks.length - 1) {
        if (value.length > 7) {
          List valuesToRemove = [];
          value.skip(7).take(value.length - 7).forEach((element) {
            weeks[index + 1].insert(0, element);
            valuesToRemove.add(element);
          });

          valuesToRemove.forEach((element) {
            value.removeWhere((e) => element == e);
          });
        }
      } else {
        if (value.length > 7) {
          List valuesToRemove = [];

          value.skip(7).take(value.length - 7).forEach((element) {
            valuesToAdd.add(element);
            valuesToRemove.add(element);
          });

          valuesToRemove.forEach((element) {
            value.removeWhere((e) => element == e);
          });
        }
      }

      return MapEntry(index, value);
    });

    return valuesToAdd;
  }

  void _createWeeks() {
    List<DateTime> allDays = [];
    final lastDayOfMonth =
        DateTime(actualDate.year, actualDate.month + 1, 0).day;

    for (int i = 1; i < lastDayOfMonth + 1; i++) {
      allDays.add(DateTime(actualDate.year, actualDate.month, i));
    }

    int x = 0;
    while (x < allDays.length) {
      List daysToAdd = allDays.skip(x).take(_daysInWeek).toList();

      weeks.add(daysToAdd);
      x += _daysInWeek;
    }

    int weekDayOfFirstWeek = allDays[0].weekday;
    int weekDayOfLastWeek = allDays.last.weekday;

    _addBeforeMonthDays(weekDayOfFirstWeek);
    _addAfterMonthDays(weekDayOfLastWeek);

    final restValues = _weekEqualizer(weeks);
    final length = restValues.length;

    if (length > 0) {
      weeks.add(restValues);
    }

    final lastWeek = weeks.last;
    final lastDayOfWeek = lastWeek.last;
    int weekDayOfLastDayWeek = lastDayOfWeek.weekday;

    if (weekDayOfLastDayWeek < _daysInWeek) {
      for (int i = 0; i < _daysInWeek - weekDayOfLastDayWeek; i++) {
        weeks.last.add(null);
      }
    }

    weeks.asMap().forEach((index, week) {
      if (index == 0) {
        if (weekDayOfFirstWeek > 1) {
          final indexOf = weeks[0].indexOf(allDays[0]);

          week.sublist(indexOf).sort((a, b) => _weekSorter(a, b));
        }
      } else if (index == weeks.length - 1) {
        if (weekDayOfLastWeek < _daysInWeek) {
          week.sublist(0, weekDayOfLastWeek).sort((a, b) => _weekSorter(a, b));
        }
      } else {
        week.sort((a, b) => _weekSorter(a, b));
      }
    });
  }

  _weekSorter(a, b) {
    if (a == null || b == null) {
      return -1;
    }
    return a.day - b.day;
  }

  void _addAfterMonthDays(int weekDayOfLastWeek) {
    if (weekDayOfLastWeek < _daysInWeek) {
      final firstDayOfNextMonth =
          DateTime(actualDate.year, actualDate.month + 1, 1);

      for (int i = 1; i < (_daysInWeek - weekDayOfLastWeek) + 1; i++) {
        weeks.last.add(
          DateTime(
            firstDayOfNextMonth.year,
            firstDayOfNextMonth.month,
            i,
          ),
        );
      }
    }
  }

  void _addBeforeMonthDays(int weekDayOfFirstWeek) {
    if (weekDayOfFirstWeek > 1) {
      final DateTime lastDayOfLastMonth =
          DateTime(actualDate.year, actualDate.month, 0);

      for (int i = lastDayOfLastMonth.day;
          i > (lastDayOfLastMonth.day - weekDayOfFirstWeek) + 1;
          i--) {
        weeks[0].insert(
          0,
          DateTime(
            lastDayOfLastMonth.year,
            lastDayOfLastMonth.month,
            i,
          ),
        );
      }
    }
  }

  void _createTableRows() {
    weeks.forEach(
      (week) {
        setState(
          () => tableRows.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: week.map<Widget>((day) {
                if (widget.dayBuilder != null) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedDate = day);

                      // Map events;

                      // if (widget.events != null) {
                      //   if (widget.events.containsKey(day)) {
                      //     events = widget.events[day];
                      //   }
                      // }

                      if (widget.onSelectDate != null) {
                        widget.onSelectDate(selectedDate, []);
                      }
                    },
                    child: widget.dayBuilder(day),
                  );
                }
                return _createDay(day);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _createDay(day) {
    double width = (MediaQuery.of(widget.ctx).size.width - 48) / 7;
    List<Color> eventColors = [];
    List<List> events = [];

    if (widget.events != null) {
      if (widget.events.containsKey(day)) {
        widget.events[day].forEach((key, value) {
          eventColors.add(key);
          events.add(value);
        });
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() => selectedDate = day);

        if (widget.onSelectDate != null) {
          widget.onSelectDate(selectedDate, events);
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: width,
              alignment: Alignment.center,
              padding: widget.events != null && widget.events.containsKey(day)
                  ? EdgeInsets.symmetric(vertical: 6)
                  : EdgeInsets.symmetric(vertical: 12),
              margin: widget.events != null && widget.events.containsKey(day)
                  ? EdgeInsets.only(top: 4)
                  : EdgeInsets.zero,
              child: day == null
                  ? Container()
                  : !widget.showOutsideDays && (day.month != actualDate.month)
                      ? Container()
                      : Text(
                          day.day.toString(),
                          style: TextStyle(
                            fontWeight: selectedDate == day
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: day.month != actualDate.month
                                ? Colors.grey
                                : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
            ),
            if (widget.events != null) ...{
              if (widget.events.containsKey(day)) ...{
                Row(
                  children: widget.events[day]
                      .map((key, value) {
                        return MapEntry(
                          key,
                          Container(
                            margin: value == widget.events[day].values.last
                                ? EdgeInsets.zero
                                : EdgeInsets.only(
                                    right: 3,
                                  ),
                            child: Row(
                                children: value.map((eventName) {
                              return Container(
                                width: 4,
                                height: 4,
                                margin: eventName == value.last
                                    ? EdgeInsets.zero
                                    : EdgeInsets.only(
                                        right: 3,
                                      ),
                                decoration: BoxDecoration(
                                  color: key,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList()),
                          ),
                        );
                      })
                      .values
                      .toList(),
                ),
              }
            }
          ],
        ),
      ),
    );
  }

  _cleanAllWeekDays() {
    setState(() {
      weeks = [];
      tableRows = [];
    });
  }

  _prevDate(DateTime date) {
    setState(
      () => actualDate = DateTime(
        date.year == actualDate.year ? date.year : date.year - 1,
        date.month - 1,
        1,
      ),
    );
    if (widget.onChangeDate != null) {
      widget.onChangeDate(actualDate);
    }
    _cleanAllWeekDays();

    if (widget.showDays) {
      _createWeeks();
    }
  }

  _nextDate(DateTime date) {
    setState(
      () => actualDate = DateTime(
        date.year == actualDate.year ? date.year : date.year + 1,
        date.month + 1,
        1,
      ),
    );
    if (widget.onChangeDate != null) {
      widget.onChangeDate(actualDate);
    }
    _cleanAllWeekDays();

    if (widget.showDays) {
      _createWeeks();
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() => tableRows = []);

    if (widget.showDays) {
      _createTableRows();
    }
    final date = DateFormat('MMMM').format(actualDate);
    final dateText = '$date ${actualDate.year.toString()}'.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: widget.showDays
              ? widget.headerStyle.margin
              : EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _prevDate(actualDate),
                child: Container(
                  padding: widget.headerStyle.padding,
                  constraints:
                      widget.headerStyle.leftChevronConstraintsContainer,
                  color: Colors.transparent,
                  child: Icon(
                    widget.headerStyle.leftChevronIcon,
                    size: widget.headerStyle.leftChevronSizeIcon,
                    color: widget.headerStyle.leftChevronColorIcon,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (widget.onTapMonthHeader != null) {
                    widget.onTapMonthHeader(actualDate);
                  }
                },
                child: Container(
                    constraints: BoxConstraints(
                      minWidth: 150,
                    ),
                    child: Text(
                      dateText,
                      textAlign: TextAlign.center,
                    )),
              ),
              GestureDetector(
                onTap: () => _nextDate(actualDate),
                child: Container(
                  padding: widget.headerStyle.padding,
                  constraints:
                      widget.headerStyle.rightChevronConstraintsContainer,
                  color: Colors.transparent,
                  child: Icon(
                    widget.headerStyle.rightChevronIcon,
                    size: widget.headerStyle.rightChevronSizeIcon,
                    color: widget.headerStyle.rightChevronColorIcon,
                  ),
                ),
              )
            ],
          ),
        ),
        if (widget.showDays) ...{
          Container(
            padding: EdgeInsets.only(
              bottom: 12,
            ),
            margin: EdgeInsets.only(
              bottom: 6,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEEEEEE),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i < _daysInWeek + 1; i++) ...{
                  Container(
                    width: (MediaQuery.of(widget.ctx).size.width - 48) / 7,
                    child: Text(
                      _getDayOfWeek(DateTime(2020, 6, i))[0],
//                      DateUtils.getDayOfWeek(
//                          DateTime(2020, 6, i), widget.ctx)[0],
//                      options: LjTextOptions.mediumCaptionBold,
//                      color: theme.ljGrey,
                      textAlign: TextAlign.center,
                    ),
                  ),
                }
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: tableRows,
          )
        },
      ],
    );
  }
}
