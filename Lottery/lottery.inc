/**
* Регистрация выигрыша.
*
* @note На каждый плагин 1 регистрация.
*		То есть, нельзя в одном плагине регистрировать
*		сразу несколько выигрышей.
* @note Обработчик будет вызван следующим образом:
*
* public lottery_prize(id)
*
*	id - индекс игрока
*
* @param drop_chance		Шанс выпадения
* @param callback			Обработчик
*
* @noreturn
*/

native register_lottery_prize(drop_chance, callback[]);