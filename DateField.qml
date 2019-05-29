import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
Item {
    id: root_control
    property var date: new Date()
    property int dialogHeight: 300
    property int dialogWidth: 300
    property string format: "dd.MM.yyyy"
    property alias mask: textEditDate.inputMask
    property alias validator: textEditDate.validator

    property alias button: bt_show_calendar

    height: 40
    width: 300

    signal dateSelected();

    Row {
        anchors.fill: parent
        TextField {
            id: textEditDate
            function getMonthFromString(mon) {
               var d = Date.parse(mon + " 1, 2012");
               if(!isNaN(d)) {
                  return new Date(d).getMonth() + 1;
               }
               return -1;
            }
            function fromFormatDate(_strDate, _format) {
                var dateString = _strDate;
                var dateParts = dateString.split(/\W/);
                var formatParts = format.split(/\W/);
                var fields = [];

                // month is 0-based, that's why we need dataParts[1] - 1
                for(var i=0; i<formatParts.length; i++) {
                    if(formatParts[i][0] === 'y') {
                        fields["year"] = +dateParts[i];
                    } else if(formatParts[i][0] === 'M') {
                        if(formatParts[i].length > 2) {
                            fields["month"] = getMonthFromString(dateParts[i]);
                        } else {
                            fields["month"] = +dateParts[i] - 1;
                        }
                    } else if(formatParts[i][0] === 'd') {
                        fields["day"] = +dateParts[i];
                    }
                }
                var dateObject = new Date(fields["year"], fields["month"], fields["day"]); // Date(year, month, day)
                //console.log(dateObject)

                return dateObject;
            }
            function getInputMask(str) {
                var regexp1 = /[\w]{1,}/;
                var regexp2 = /\W/;

                var splitted_sp = str.split(regexp1);
                var splitted_date = str.split(regexp2);
                var spacer_list = splitted_sp.filter(function (el) {
                    return el !== "";
                });
                var mask="";

                var regexp_alpha = /\w{3,4}/;
                var regexp_digit = /\d{1,4}/;
                for(var i=0; i<splitted_date.length; i++) {
                    if(regexp_digit.test(splitted_date[i])) {
                        if(splitted_date[i].length < 3) {
                            mask += "99";
                        } else {
                            mask += "9999";
                        }
                    }
                    else if(regexp_alpha.test(splitted_date[i])) {
                        if(splitted_date[i].length < 4) {
                            mask += "AAA";
                        } else {
                            mask += "AAAA";
                        }
                    }
                    if(i<spacer_list.length) {
                        mask += spacer_list[i];
                    }
                }
                return mask;
            }

            width: root_control.width*0.9
            height: root_control.height
            text: Qt.formatDate(date,format)

            inputMask: getInputMask(Qt.formatDate(date,format)) // or manual enter, example: "99.99.9999"
            validator: RegExpValidator {
                regExp: /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/
            }

//            style: TextFieldStyle {
//                    textColor: "black"
//                    background: Rectangle {
//                        color: "transparent"
//                    }
//            }

            horizontalAlignment: Text.AlignHCenter
            inputMethodHints: Qt.ImhDigitsOnly

            onEditingFinished: {
                date = fromFormatDate(textEditDate.text);
                calendar.selectedDate = date;
                root_control.dateSelected();
            }
        }
        Button {
            id: bt_show_calendar
            text: ""
            width: 0.1*textEditDate.width
            height: textEditDate.height

            onClicked: {
                dialog_calendar.open();
            }
            style: ButtonStyle {
                label: Text {
                    text: qsTr(bt_show_calendar.text)
                    font.pixelSize: 8
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
    Dialog {
        id: dialog_calendar
        title: qsTr("Выбор даты")
        width: dialogWidth
        height: dialogHeight
        contentItem: Rectangle {
            width: dialog_calendar.width
            height: dialog_calendar.height
            Calendar {
                id: calendar
                anchors.fill: parent
                frameVisible: true
                weekNumbersVisible: true
                selectedDate: root_control.date
                focus: true
                onClicked: {
                    if(root_control.date !== date) {
                        root_control.date = date;
                        dialog_calendar.click(StandardButton.Save)
                        root_control.dateSelected();
                    }
                }
            }
        }
    }
}
