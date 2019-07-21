//
// Copyright (C) 2013-2018 University of Amsterdam
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//
import QtQuick 2.8
import QtQuick.Layouts 1.3
import JASP.Controls 1.0
import JASP.Widgets 1.0

Form 
{
    id: form

	GroupBox
	{
		IntegerField
		{
			id:				housePrice
			name:			"housePrice"
			defaultValue:	300000
			min:			0
			max:			1000000000
			text:			"House Price: "
			fieldWidth:		200
		}
		
		IntegerField
		{
			name:			"years"
			defaultValue:	30
			min:			1
			max:			100
			text:			"Period: "
			toolTip:		"How long will it take you to pay the mortgage back?"
			fieldWidth:		housePrice.fieldWidth
		}

		PercentField
		{
			name:			"interest"
			defaultValue:	2
			text:			"Interest: "
			fieldWidth:		housePrice.fieldWidth
		}
	}

	GroupBox
	{
		/*PercentField
		{
			id:				taxRate
			name:			"taxrate"
			defaultValue:	40
			text:			"Tax rate: "
			fieldWidth:		100
		}*/

		DoubleField
		{
			name:			"rent"
			defaultValue:	1300
			min:			0
			max:			10000
			text:			"Rent: "
			fieldWidth:		taxRate.fieldWidth
		}
	}

    CheckBox
    {
        name: 		"linear"
        checked: 	true
		text:		"Linear Mortgage?"
    }

	CheckBox
    {
        name: 		"perYear"
        checked: 	true
		text:		"Only years?"
    }
}
