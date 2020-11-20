// CMSC 430
// Duane J. Jarc

// This file contains the bodies of the evaluation functions

#include <string>
#include <vector>
#include <cmath>

using namespace std;

#include "values.h"
#include "listing.h"

double evaluateReduction(Operators operator_, double head, double tail)
{
	if (operator_ == ADD)
		return head + tail;
	return head * tail;
}

double evaluateRelational(double left, Operators operator_, double right)
{
	double result;
	switch (operator_)
	{
	case LESS:
		result = left < right;
		break;
	case GREATER:
		result = left > right;
		break;
	case ELESS:
		result = left <= right;
		break;
	case EGREATER:
		result = left >= right;
		break;
	case EQUAL:
		result = left == right;
		break;
	case NOTEQUAL:
		result = left != right;
		break;
	}
	return result;
}

double evaluateArithmetic(double left, Operators operator_, double right)
{
	double result;
	switch (operator_)
	{
	case ADD:
		result = left + right;
		break;
	case SUBTRACT:
		result = left - right;
		break;
	case MULTIPLY:
		result = left * right;
		break;
	case DIVIDE:
		result = left / right;
		break;
	case REMAINDER:
		result = (int)left % (int)right;
		break;
	case EXPONENT:
		result = pow(left, right);
		break;
	}
	return result;
}
