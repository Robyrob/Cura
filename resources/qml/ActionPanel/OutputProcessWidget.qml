// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import UM 1.1 as UM
import Cura 1.0 as Cura


// This element contains all the elements the user needs to visualize the data
// that is gather after the slicing process, such as printint time, material usage, ...
// There are also two buttons: one to previsualize the output layers, and the other to
// select what to do with it (such as print over network, save to file, ...)
Column
{
    id: widget

    spacing: UM.Theme.getSize("thin_margin").height
    property bool preSlicedData: PrintInformation.preSliced

    UM.I18nCatalog
    {
        id: catalog
        name: "cura"
    }

    Item
    {
        id: information
        width: parent.width
        height: childrenRect.height

        Column
        {
            id: timeAndCostsInformation
            spacing: UM.Theme.getSize("thin_margin").height

            anchors
            {
                left: parent.left
                right: parent.right
            }

            Cura.IconWithText
            {
                id: estimatedTime
                width: parent.width

                text: preSlicedData ? catalog.i18nc("@label", "No time estimation available") : PrintInformation.currentPrintTime.getDisplayString(UM.DurationFormat.Long)
                source: UM.Theme.getIcon("clock")
                font: UM.Theme.getFont("default_bold")
                PrintInformationWidget
                {
                    id: printInformationPanel
                    visible: !preSlicedData
                    anchors.left: parent.left
                    anchors.leftMargin: parent.contentWidth + UM.Theme.getSize("default_margin").width
                }
            }

            Cura.IconWithText
            {
                id: estimatedCosts
                width: parent.width

                property var printMaterialLengths: PrintInformation.materialLengths
                property var printMaterialWeights: PrintInformation.materialWeights

                text:
                {
                    if (preSlicedData)
                    {
                        return catalog.i18nc("@label", "No cost estimation available")
                    }
                    var totalLengths = 0
                    var totalWeights = 0
                    if (printMaterialLengths)
                    {
                        for(var index = 0; index < printMaterialLengths.length; index++)
                        {
                            if(printMaterialLengths[index] > 0)
                            {
                                totalLengths += printMaterialLengths[index]
                                totalWeights += Math.round(printMaterialWeights[index])
                            }
                        }
                    }
                    return totalWeights + "g · " + totalLengths.toFixed(2) + "m"
                }
                source: UM.Theme.getIcon("spool")

                Item
                {
                    id: additionalComponents
                    width: childrenRect.width
                    anchors.right: parent.right
                    height: parent.height
                    Row
                    {
                        id: additionalComponentsRow
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        spacing: UM.Theme.getSize("default_margin").width
                    }
                }
                Component.onCompleted: addAdditionalComponents("saveButton")

                Connections
                {
                    target: CuraApplication
                    onAdditionalComponentsChanged: addAdditionalComponents("saveButton")
                }

                function addAdditionalComponents (areaId)
                {
                    if(areaId == "saveButton")
                    {
                        for (var component in CuraApplication.additionalComponents["saveButton"])
                        {
                            CuraApplication.additionalComponents["saveButton"][component].parent = additionalComponentsRow
                        }
                    }
                }
            }
        }


    }

    Item
    {
        id: buttonRow
        anchors.right: parent.right
        anchors.left: parent.left
        height: UM.Theme.getSize("action_button").height

        Cura.SecondaryButton
        {
            id: previewStageShortcut

            anchors
            {
                left: parent.left
                right: outputDevicesButton.left
                rightMargin: UM.Theme.getSize("default_margin").width
            }

            height: UM.Theme.getSize("action_button").height
            text: catalog.i18nc("@button", "Preview")
            tooltip: text
            fixedWidthMode: true

            toolTipContentAlignment: Cura.ToolTip.ContentAlignment.AlignLeft

            onClicked: UM.Controller.setActiveStage("PreviewStage")
            visible: UM.Controller.activeStage != null && UM.Controller.activeStage.stageId != "PreviewStage"
        }

        Cura.OutputDevicesActionButton
        {
            id: outputDevicesButton

            anchors.right: parent.right
            width: previewStageShortcut.visible ? UM.Theme.getSize("action_button").width : parent.width
            height: UM.Theme.getSize("action_button").height
        }
    }
}