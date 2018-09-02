/**
* Registration of a new lottery win.
*
* @note In 1 plugin there can be only 1 registration.
* @note Call the handler in the following manner:
*
* public lottery_prize(id)
*
*	id - Player index
*
* @param chance				The probability of obtaining
* @param handler			Callback function
*
* @return					Forward handle
*/

native register_lottery_prize(chance, handler[]);