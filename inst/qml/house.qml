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
		title:		"Mortgage"
		
		IntegerField
		{
			id:				housePrice
			name:			"housePrice"
			defaultValue:	300000
			min:			0
			max:			1000000000
			text:			"House Price: "
			fieldWidth:		100
			toolTip:		"How big will the mortgage be?"
		}

		IntegerField
		{
			name:			"lossOnSale"
			defaultValue:	0
			min:			0
			max:			parseFloat(housePrice.value)
			text:			"Loss on sale: "
			fieldWidth:		100
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
			toolTip:		"What will be your yearly interest?"
		}

		CheckBox
		{
			name: 		"linear"
			checked: 	true
			text:		"Linear Mortgage?"
		}
	
	}

	GroupBox
	{
		title:	"Renting"

		DoubleField
		{
			id:				rent
			name:			"rent"
			defaultValue:	1300
			min:			0
			max:			10000
			text:			"Rent: "
			fieldWidth:		100
		}

		PercentField
		{
			name:			"rentIncrease"
			defaultValue:	0
			text:			"Rent increase/year: "
			fieldWidth:		100
		}
	}

	GroupBox
	{
		title:		"Table Options"

		CheckBox
		{
			name: 		"perYear"
			checked: 	true
			text:		"Yearly overview"
		}
	}

/*
	GroupBox
	{
		title: 		"Taxes & Death"

		Label
		{
			text: "<i>Quite specific to the Netherlands</i>"
		}

		CheckBox
		{
			id:			taxesToo
			name: 		"taxesToo"
			text:		"Take taxes into account for profit"
			checked: 	false 
		}

		PercentField
		{
			name:			"taxrate"
			defaultValue:	40
			text:			"Tax rate: "
			fieldWidth:		100
			enabled:		taxesToo.checked
		}

		PercentField
		{
			name:			"forfait"
			defaultValue:	0.75
			text:			"Eigen Woning Forfait: "
			fieldWidth:		100
			enabled:		taxesToo.checked
		}
	} */
}
