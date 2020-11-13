///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ПараметрыПродолжения;
&НаКлиенте
Перем РезультатВыполненияОбновления;
&НаКлиенте
Перем ОбработкаЗавершения;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ВыполняетсяОбновлениеВерсииИБ = Истина;
	ВремяНачалаОбновления = ТекущаяДатаСеанса();
	
	КлиентСервер  = Не ОбщегоНазначения.ИнформационнаяБазаФайловая();
	Коробка       = Не ОбщегоНазначения.РазделениеВключено();
	
	ПрогрессВыполнения = 5;
	
	РежимОбновленияДанных = ОбновлениеИнформационнойБазыСлужебный.РежимОбновленияДанных();
	
	ТолькоОбновлениеПараметровРаботыПрограммы =
		Не ОбновлениеИнформационнойБазы.НеобходимоОбновлениеИнформационнойБазы();
	
	Если ТолькоОбновлениеПараметровРаботыПрограммы Тогда
		Заголовок = НСтр("ru = 'Обновление параметров работы программы'");
		Элементы.РежимЗапуска.ТекущаяСтраница = Элементы.ОбновлениеПараметровРаботыПрограммы;
		
	ИначеЕсли РежимОбновленияДанных = "НачальноеЗаполнение" Тогда
		Заголовок = НСтр("ru = 'Начальное заполнение данных'");
		Элементы.РежимЗапуска.ТекущаяСтраница = Элементы.НачальноеЗаполнение;
		
	ИначеЕсли РежимОбновленияДанных = "ПереходСДругойПрограммы" Тогда
		Заголовок = НСтр("ru = 'Переход с другой программы'");
		Элементы.РежимЗапуска.ТекущаяСтраница = Элементы.ПереходСДругойПрограммы;
		Элементы.ТекстСообщенияПереходСДругойПрограммы.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			Элементы.ТекстСообщенияПереходСДругойПрограммы.Заголовок, Метаданные.Синоним);
	Иначе
		Заголовок = НСтр("ru = 'Обновление версии программы'");
		Элементы.РежимЗапуска.ТекущаяСтраница = Элементы.ОбновлениеВерсииПрограммы;
		Элементы.ТекстСообщенияОбновляемаяКонфигурация.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			Элементы.ТекстСообщенияОбновляемаяКонфигурация.Заголовок, Метаданные.Версия);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	Если ВыполняетсяОбновлениеВерсииИБ Тогда
		Отказ = Истина;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ТехническаяИнформацияНажатие(Элемент)
	
	ПараметрыОтбора = Новый Структура;
	ПараметрыОтбора.Вставить("ЗапускатьНеВФоне", Истина);
	ПараметрыОтбора.Вставить("ДатаНачала", ВремяНачалаОбновления);
	ЖурналРегистрацииКлиент.ОткрытьЖурналРегистрации(ПараметрыОтбора);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Обновление параметров работы программы и неразделенных данных в сервисе.

&НаКлиенте
Процедура ЗагрузитьОбновитьПараметрыРаботыПрограммы(Параметры) Экспорт
	
	ПараметрыПродолжения = Параметры;
	ПодключитьОбработчикОжидания("НачатьЗагрузкуПараметровРаботыПрограммы", 0.1, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура НачатьЗагрузкуПараметровРаботыПрограммы()
	
	РезультатВыполнения = ЗагрузитьПараметрыРаботыПрограммыВФоне();
	
	ДополнительныеПараметры = Новый Структура("КраткоеПредставлениеОшибки, ПодробноеПредставлениеОшибки");
	
	Если РезультатВыполнения = "ТребуетсяПерезапускСеанса" Тогда
		ПрекратитьРаботуСистемы(Истина);
		
	ИначеЕсли РезультатВыполнения = "ЗагрузкаПараметровРаботыПрограммыНеТребуется" Тогда
		Результат = Новый Структура("Статус", РезультатВыполнения);
		НачатьОбновлениеПараметровРаботыПрограммы(Результат, ДополнительныеПараметры);
		Возврат;
		
	ИначеЕсли РезультатВыполнения = "ЗагрузкаИОбновлениеПараметровРаботыПрограммыНеТребуются" Тогда
		Результат = Новый Структура("Статус", РезультатВыполнения);
		НачатьОбновлениеПараметровРаботыВерсийРасширений(Результат, ДополнительныеПараметры);
		Возврат;
	КонецЕсли;
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения("НачатьОбновлениеПараметровРаботыПрограммы",
		ЭтотОбъект, ДополнительныеПараметры);
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
	ПараметрыОжидания.Интервал = 1;
	ПараметрыОжидания.ВыводитьПрогрессВыполнения = Истина;
	ПараметрыОжидания.ОповещениеОПрогрессеВыполнения = Новый ОписаниеОповещения("ПрогрессОбновленияПараметровРаботыПрограммы", ЭтотОбъект); 
	ДлительныеОперацииКлиент.ОжидатьЗавершение(РезультатВыполнения, ОповещениеОЗавершении, ПараметрыОжидания);
	
КонецПроцедуры

&НаСервере
Функция ЗагрузитьПараметрыРаботыПрограммыВФоне()
	
	ОбновитьПовторноИспользуемыеЗначения();
	
	Если ОбщегоНазначения.РазделениеВключено()
	   И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		Возврат "ЗагрузкаИОбновлениеПараметровРаботыПрограммыНеТребуются";
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбновлениеКонфигурации") Тогда
		МодульОбновлениеКонфигурации = ОбщегоНазначения.ОбщийМодуль("ОбновлениеКонфигурации");
		Результат = МодульОбновлениеКонфигурации.ИсправленияИзменены();
		Если Результат.ЕстьИзменения Тогда
			Возврат "ТребуетсяПерезапускСеанса";
		КонецЕсли;
	КонецЕсли;
	
	Если Не РегистрыСведений.ПараметрыРаботыПрограммы.ТребуетсяЗагрузитьПараметрыРаботыПрограммы() Тогда
		Возврат "ЗагрузкаПараметровРаботыПрограммыНеТребуется";
	КонецЕсли;
	
	// Вызов длительной операции (обычно в фоновом задании).
	Возврат РегистрыСведений.ПараметрыРаботыПрограммы.ЗагрузитьПараметрыРаботыПрограммыВФоне(0,
		УникальныйИдентификатор, Истина);
	
КонецФункции

&НаКлиенте
Процедура ПрогрессОбновленияПараметровРаботыПрограммы(Прогресс, ДополнительныеПараметры) Экспорт
	
	Если Прогресс = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Прогресс.Статус <> "Выполняется" Тогда
		Возврат;
	КонецЕсли;
	
	Если Прогресс.Прогресс <> Неопределено Тогда
		
		Если ТолькоОбновлениеПараметровРаботыПрограммы Тогда
			ПрогрессВыполнения = 5 + (90 * Прогресс.Прогресс.Процент / 100);
		Иначе
			ПрогрессВыполнения = 5 + (5 * Прогресс.Прогресс.Процент / 100);
		КонецЕсли;
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура НачатьОбновлениеПараметровРаботыПрограммы(Результат, ДополнительныеПараметры) Экспорт
	
	Попытка
		ОбработанныйРезультат = ОбработанныйРезультатДлительнойОперации(Результат,
			"ЗагрузкаПараметровРаботыПрограммы");
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ОбработанныйРезультат = Новый Структура;
		ОбработанныйРезультат.Вставить("КраткоеПредставлениеОшибки",
			КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		ОбработанныйРезультат.Вставить("ПодробноеПредставлениеОшибки",
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	КонецПопытки;
	
	Если ЗначениеЗаполнено(ОбработанныйРезультат.КраткоеПредставлениеОшибки) Тогда
		СообщениеОНеудачномОбновлении(ОбработанныйРезультат, Неопределено);
		Возврат;
	КонецЕсли;
	
	РезультатВыполнения = ОбновитьПараметрыРаботыПрограммыВФоне();
	
	ДополнительныеПараметры = Новый Структура("КраткоеПредставлениеОшибки, ПодробноеПредставлениеОшибки");
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения("НачатьОбновлениеПараметровРаботыВерсийРасширений",
		ЭтотОбъект, ДополнительныеПараметры);
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
	ПараметрыОжидания.Интервал = 1;
	ПараметрыОжидания.ВыводитьПрогрессВыполнения = Истина;
	ПараметрыОжидания.ОповещениеОПрогрессеВыполнения = Новый ОписаниеОповещения("ПрогрессОбновленияПараметровРаботыПрограммы", ЭтотОбъект); 
	ДлительныеОперацииКлиент.ОжидатьЗавершение(РезультатВыполнения, ОповещениеОЗавершении, ПараметрыОжидания);
	
КонецПроцедуры

&НаСервере
Функция ОбновитьПараметрыРаботыПрограммыВФоне()
	
	// Вызов длительной операции (обычно в фоновом задании).
	Возврат РегистрыСведений.ПараметрыРаботыПрограммы.ОбновитьПараметрыРаботыПрограммыВФоне(0,
		УникальныйИдентификатор, Истина);
	
КонецФункции

&НаКлиенте
Процедура НачатьОбновлениеПараметровРаботыВерсийРасширений(Результат, ДополнительныеПараметры) Экспорт
	
	Попытка
		ОбработанныйРезультат = ОбработанныйРезультатДлительнойОперации(Результат,
			"ОбновлениеПараметровРаботыПрограммы");
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ОбработанныйРезультат = Новый Структура;
		ОбработанныйРезультат.Вставить("КраткоеПредставлениеОшибки",
			КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		ОбработанныйРезультат.Вставить("ПодробноеПредставлениеОшибки",
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	КонецПопытки;
	
	Если ЗначениеЗаполнено(ОбработанныйРезультат.КраткоеПредставлениеОшибки) Тогда
		СообщениеОНеудачномОбновлении(ОбработанныйРезультат, Неопределено);
		Возврат;
	КонецЕсли;
	
	РезультатВыполнения = ОбновитьПараметрыРаботыВерсийРасширенийВФоне();
	
	Если РезультатВыполнения = "ОбновлениеПараметровРаботыВерсийРасширенийНеТребуется" Тогда
		Результат = Новый Структура("Статус", РезультатВыполнения);
		ЗавершитьОбновлениеПараметровРаботыПрограммы(Результат, ДополнительныеПараметры);
		Возврат;
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура("КраткоеПредставлениеОшибки, ПодробноеПредставлениеОшибки");
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения("ЗавершитьОбновлениеПараметровРаботыПрограммы",
		ЭтотОбъект, ДополнительныеПараметры);
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
	ПараметрыОжидания.Интервал = 1;
	ПараметрыОжидания.ВыводитьПрогрессВыполнения = Истина;
	ПараметрыОжидания.ОповещениеОПрогрессеВыполнения = Новый ОписаниеОповещения("ПрогрессОбновленияПараметровРаботыПрограммы", ЭтотОбъект); 
	ДлительныеОперацииКлиент.ОжидатьЗавершение(РезультатВыполнения, ОповещениеОЗавершении, ПараметрыОжидания);
	
КонецПроцедуры

&НаСервере
Функция ОбновитьПараметрыРаботыВерсийРасширенийВФоне()
	
	Если Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		Возврат "ОбновлениеПараметровРаботыВерсийРасширенийНеТребуется";
	КонецЕсли;
	
	// Вызов длительной операции (обычно в фоновом задании).
	Возврат РегистрыСведений.ПараметрыРаботыПрограммы.ОбновитьПараметрыРаботыВерсийРасширенийВФоне(0,
		УникальныйИдентификатор, Истина);
	
КонецФункции

&НаКлиенте
Процедура ЗавершитьОбновлениеПараметровРаботыПрограммы(Результат, ДополнительныеПараметры) Экспорт
	
	Попытка
		ОбработанныйРезультат = ОбработанныйРезультатДлительнойОперации(Результат,
			"ОбновлениеПараметровРаботыВерсийРасширений");
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ОбработанныйРезультат = Новый Структура;
		ОбработанныйРезультат.Вставить("КраткоеПредставлениеОшибки",
			КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		ОбработанныйРезультат.Вставить("ПодробноеПредставлениеОшибки",
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	КонецПопытки;
	
	Если ЗначениеЗаполнено(ОбработанныйРезультат.КраткоеПредставлениеОшибки) Тогда
		СообщениеОНеудачномОбновлении(ОбработанныйРезультат, Неопределено);
		Возврат;
	КонецЕсли;
	
	ПараметрыПродолжения.ПолученныеПараметрыКлиента.Вставить("НеобходимоОбновлениеПараметровРаботыПрограммы");
	ПараметрыПродолжения.Вставить("КоличествоПолученныхПараметровКлиента",
		ПараметрыПродолжения.ПолученныеПараметрыКлиента.Количество());
	
	ОбновитьПовторноИспользуемыеЗначения();
	
	Попытка
		ПараметрыКлиента = СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске();
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ДополнительныеПараметры.Вставить("КраткоеПредставлениеОшибки", КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		ДополнительныеПараметры.Вставить("ПодробноеПредставлениеОшибки", ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
		СообщениеОНеудачномОбновлении(ДополнительныеПараметры, Неопределено);
		Возврат;
	КонецПопытки;
	
	Если Не ТолькоОбновлениеПараметровРаботыПрограммы
	   И ПараметрыКлиента.ДоступноИспользованиеРазделенныхДанных Тогда
		
		ВыполнитьОбработкуОповещения(ПараметрыПродолжения.ОбработкаПродолжения);
		Возврат;
	КонецЕсли;
		
	Если ПараметрыКлиента.Свойство("НеобходимоОбновлениеНеразделенныхДанныхИнформационнойБазы") Тогда
		Попытка
			ОбновлениеИнформационнойБазыСлужебныйВызовСервера.ВыполнитьОбновлениеИнформационнойБазы(Истина);
		Исключение
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			ДополнительныеПараметры.Вставить("КраткоеПредставлениеОшибки",   КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
			ДополнительныеПараметры.Вставить("ПодробноеПредставлениеОшибки", ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
		КонецПопытки;
		Если ЗначениеЗаполнено(ДополнительныеПараметры.КраткоеПредставлениеОшибки) Тогда
			СообщениеОНеудачномОбновлении(ДополнительныеПараметры, Неопределено);
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	Если БлокировкаИБ <> Неопределено
		И БлокировкаИБ.Свойство("СнятьБлокировкуФайловойБазы") Тогда
		ОбновлениеИнформационнойБазыСлужебныйВызовСервера.СнятьБлокировкуФайловойБазы();
	КонецЕсли;
	ЗакрытьФорму(Ложь, Ложь);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обновление информационной базы (все в локальном режиме и область данных в сервисе).

&НаКлиенте
Процедура ОбновитьИнформационнуюБазу() Экспорт
	
	ПрогрессВыполнения = 10;
	ПодключитьОбработчикОжидания("НачатьОбновлениеИнформационнойБазы", 0.1, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура НачатьОбновлениеИнформационнойБазы()
	
	ВремяНачалаОбновления = ОбщегоНазначенияКлиент.ДатаСеанса();
	
	РезультатОбновленияИБ = ОбновитьИнформационнуюБазуВФоне();
	
	Если Не РезультатОбновленияИБ.Свойство("АдресРезультата") Тогда
		ЗавершитьОбновлениеИнформационнойБазы(РезультатОбновленияИБ, Неопределено);
		Возврат;
	КонецЕсли;
	
	Если КлиентСервер И Коробка Тогда
		ПроцедураПродолжения = "ЗарегистрироватьДанныеДляОтложенногоОбновления";
	Иначе
		ПроцедураПродолжения = "ЗавершитьОбновлениеИнформационнойБазы";
	КонецЕсли;
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения(ПроцедураПродолжения, ЭтотОбъект);
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
	ПараметрыОжидания.ВыводитьПрогрессВыполнения = Истина;
	ПараметрыОжидания.ВыводитьСообщения = Истина;
	ПараметрыОжидания.ОповещениеОПрогрессеВыполнения = Новый ОписаниеОповещения("ПрогрессОбновленияИнформационнойБазы", ЭтотОбъект); 
	ДлительныеОперацииКлиент.ОжидатьЗавершение(РезультатОбновленияИБ, ОповещениеОЗавершении, ПараметрыОжидания);
	
КонецПроцедуры

&НаСервере
Функция ОбновитьИнформационнуюБазуВФоне()
	
	Результат = ОбновлениеИнформационнойБазыСлужебный.ОбновитьИнформационнуюБазуВФоне(УникальныйИдентификатор, БлокировкаИБ);
	БлокировкаИБ = Результат.БлокировкаИБ;
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Процедура ПрогрессОбновленияИнформационнойБазы(Прогресс, ДополнительныеПараметры) Экспорт
	
	Если Прогресс = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Прогресс.Статус = "Ошибка" Тогда
		Возврат;
	КонецЕсли;
	
	Если Прогресс.Свойство("ДополнительныеПараметры")
		И Прогресс.ДополнительныеПараметры.Свойство("ОбменДанными") Тогда
		Возврат;
	КонецЕсли;
	
	Если Прогресс.Прогресс <> Неопределено Тогда
		ПрогрессВыполнения = 10 + (90 * Прогресс.Прогресс.Процент / 100);
	КонецЕсли;
	ОбработатьОшибкуПравилРегистрации(Прогресс.Сообщения);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗавершитьОбновлениеИнформационнойБазы(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Или Результат.Статус = "Отменено" Тогда
		
		ПризнакВыполненияОбработчиков = БлокировкаИБ.Ошибка;
		
	ИначеЕсли Результат.Статус = "Выполнено"  Тогда
		
		РезультатОбновления = ПолучитьИзВременногоХранилища(Результат.АдресРезультата);
		Если ТипЗнч(РезультатОбновления) = Тип("Структура") Тогда
			Если РезультатОбновления.Свойство("КраткоеПредставлениеОшибки")
				И РезультатОбновления.Свойство("ПодробноеПредставлениеОшибки") Тогда
				Результат.КраткоеПредставлениеОшибки = РезультатОбновления.КраткоеПредставлениеОшибки;
				Результат.ПодробноеПредставлениеОшибки = РезультатОбновления.ПодробноеПредставлениеОшибки;
			Иначе
				ПризнакВыполненияОбработчиков = РезультатОбновления.Результат;
				УстановитьПараметрыСеансаИзФоновогоЗадания(РезультатОбновления.ПараметрыКлиентаНаСервере);
				ПрогрессВыполнения = 100;
			КонецЕсли;
		Иначе
			ПризнакВыполненияОбработчиков = РезультатОбновления;
		КонецЕсли;
		ОбработатьОшибкуПравилРегистрации(Результат.Сообщения);
		
	Иначе // ошибка
		ПризнакВыполненияОбработчиков = БлокировкаИБ.Ошибка;
	КонецЕсли;
	
	Если ПризнакВыполненияОбработчиков = "ЗаблокироватьВыполнениеРегламентныхЗаданий" Тогда
		ПерезапускСБлокировкойВыполненияРегламентныхЗаданий();
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ДокументОписаниеОбновлений", Неопределено);
	ДополнительныеПараметры.Вставить("КраткоеПредставлениеОшибки", Результат.КраткоеПредставлениеОшибки);
	ДополнительныеПараметры.Вставить("ПодробноеПредставлениеОшибки", Результат.ПодробноеПредставлениеОшибки);
	ДополнительныеПараметры.Вставить("ВремяНачалаОбновления", ВремяНачалаОбновления);
	ДополнительныеПараметры.Вставить("ВремяОкончанияОбновления", ОбщегоНазначенияКлиент.ДатаСеанса());
	ДополнительныеПараметры.Вставить("ПризнакВыполненияОбработчиков", ПризнакВыполненияОбработчиков);
	
	Если ПризнакВыполненияОбработчиков = "ОшибкаУстановкиМонопольногоРежима" Тогда
		
		ОбновитьИнформационнуюБазуПриОшибкеУстановкиМонопольногоРежима(ДополнительныеПараметры);
		Возврат;
		
	КонецЕсли;
	
	СнятьБлокировкуФайловойБазы = Ложь;
	Если БлокировкаИБ.Свойство("СнятьБлокировкуФайловойБазы", СнятьБлокировкуФайловойБазы) Тогда
		
		Если СнятьБлокировкуФайловойБазы Тогда
			ОбновлениеИнформационнойБазыСлужебныйВызовСервера.СнятьБлокировкуФайловойБазы();
		КонецЕсли;
		
	КонецЕсли;
	
	ОбновитьИнформационнуюБазуЗавершение(ДополнительныеПараметры);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьОшибкуПравилРегистрации(СообщенияПользователю)
	
	// См. ОбменДаннымиСобытия.ОбработатьОшибкуПравилРегистрации
	Если СообщенияПользователю <> Неопределено Тогда
		Для Каждого СообщениеПользователю Из СообщенияПользователю Цикл
			
			НачалоСтроки = "ОбменДанными=";
			Если СтрНачинаетсяС(СообщениеПользователю.Текст, НачалоСтроки) Тогда
				ИмяПланаОбмена = Сред(СообщениеПользователю.Текст, СтрДлина(НачалоСтроки) + 1);
			КонецЕсли;
			
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИнформационнуюБазуПриОшибкеУстановкиМонопольногоРежима(ДополнительныеПараметры)
	
	Если ДополнительныеПараметры.ПризнакВыполненияОбработчиков <> "ОшибкаУстановкиМонопольногоРежима" Тогда
		ОбновитьИнформационнуюБазуЗавершение(ДополнительныеПараметры);
		Возврат;
	КонецЕсли;
	
	Если Не ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ЗавершениеРаботыПользователей") Тогда
		СообщениеОНеудачномОбновлении(ДополнительныеПараметры, Неопределено);
		Возврат;
	КонецЕсли;
	
	// Открытие формы для отключения активных сеансов.
	Оповещение = Новый ОписаниеОповещения("ОбновитьИнформационнуюБазуПриОшибкеУстановкиМонопольногоРежимаЗавершение",
		ЭтотОбъект, ДополнительныеПараметры);
	
	МодульСоединенияИБКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("СоединенияИБКлиент");
	МодульСоединенияИБКлиент.ПриОткрытииФормыОшибкиУстановкиМонопольногоРежима(Оповещение);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИнформационнуюБазуПриОшибкеУстановкиМонопольногоРежимаЗавершение(Отказ, ДополнительныеПараметры) Экспорт
	
	Если Отказ <> Ложь Тогда
		ЗакрытьФорму(Истина, Ложь);
		Возврат;
	КонецЕсли;
	
	УстановитьПараметрыБлокировкиИБПриОшибкеУстановкиМонопольногоРежима();
	НачатьОбновлениеИнформационнойБазы();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПараметрыБлокировкиИБПриОшибкеУстановкиМонопольногоРежима()
	
	Если БлокировкаИБ = Неопределено Тогда
		БлокировкаИБ = Новый Структура;
	КонецЕсли;
	
	БлокировкаИБ.Вставить("Установлена", Ложь);
	БлокировкаИБ.Вставить("СнятьБлокировкуФайловойБазы", Истина);
	БлокировкаИБ.Вставить("Ошибка", Неопределено);
	БлокировкаИБ.Вставить("ОперативноеОбновление", Неопределено);
	БлокировкаИБ.Вставить("КлючЗаписи", Неопределено);
	БлокировкаИБ.Вставить("РежимОтладки", Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИнформационнуюБазуЗавершение(ДополнительныеПараметры)
	
	Если ЗначениеЗаполнено(ДополнительныеПараметры.КраткоеПредставлениеОшибки) Тогда
		
		ВремяОкончанияОбновления = ОбщегоНазначенияКлиент.ДатаСеанса();
		СообщениеОНеудачномОбновлении(ДополнительныеПараметры, ВремяОкончанияОбновления);
		Возврат;
		
	КонецЕсли;
	
	ОбновитьИнформационнуюБазуЗавершениеСервер(ДополнительныеПараметры);
	ОбновитьПовторноИспользуемыеЗначения();
	
	ЗакрытьФорму(Ложь, Ложь);
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьИнформационнуюБазуЗавершениеСервер(ДополнительныеПараметры)
	
	// Если обновление ИБ завершилось - разблокируем ИБ.
	ОбновлениеИнформационнойБазыСлужебный.РазблокироватьИБ(БлокировкаИБ);
	ОбновлениеИнформационнойБазыСлужебный.ЗаписатьВремяВыполненияОбновления(
		ДополнительныеПараметры.ВремяНачалаОбновления, ДополнительныеПараметры.ВремяОкончанияОбновления);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытьФорму(Отказ, Перезапустить)
	
	ВыполняетсяОбновлениеВерсииИБ = Ложь;
	Закрыть(Новый Структура("Отказ, Перезапустить", Отказ, Перезапустить));
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Регистрация данных для параллельного отложенного обновления.

&НаКлиенте
Процедура ЗарегистрироватьДанныеДляОтложенногоОбновления(Результат, ДополнительныеПараметры) Экспорт
	
	РезультатОбновления = ПолучитьИзВременногоХранилища(Результат.АдресРезультата);
	
	ОбработкаЗавершения = Новый ОписаниеОповещения("ЗавершитьОбновлениеИнформационнойБазы", ЭтотОбъект, Результат);
	РезультатВыполненияОбновления = Результат;
	Если Результат.Статус <> "Выполнено"
		Или (ТипЗнч(РезультатОбновления) = Тип("Структура")
			И РезультатОбновления.Свойство("КраткоеПредставлениеОшибки")
			И РезультатОбновления.Свойство("ПодробноеПредставлениеОшибки")) Тогда
		ВыполнитьОбработкуОповещения(ОбработкаЗавершения, РезультатВыполненияОбновления);
		Возврат;
	КонецЕсли;
	
	СостояниеРегистрации = ЗаполнениеДанныхДляПараллельногоОтложенногоОбновления();
	Если СостояниеРегистрации.Статус <> "Выполняется" Тогда
		ЗаполнитьЗначенияСвойств(РезультатВыполненияОбновления, СостояниеРегистрации, "Статус,КраткоеПредставлениеОшибки,ПодробноеПредставлениеОшибки");
		ВыполнитьОбработкуОповещения(ОбработкаЗавершения, РезультатВыполненияОбновления);
	Иначе
		ИдентификаторЗадания = СостояниеРегистрации.ИдентификаторЗадания;
		ПодключитьОбработчикОжидания("Подключаемый_ПроверитьПроцедурыЗаполненияОтложенныхОбработчиков", 5);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ЗаполнениеДанныхДляПараллельногоОтложенногоОбновления()
	
	// Очистка плана обмена ОбновлениеИнформационнойБазы.
	Если Не (СтандартныеПодсистемыПовтИсп.ИспользуетсяРИБ("СФильтром") И ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ()) Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОбновлениеИнформационнойБазы.Ссылка КАК Узел
		|ИЗ
		|	ПланОбмена.ОбновлениеИнформационнойБазы КАК ОбновлениеИнформационнойБазы
		|ГДЕ
		|	НЕ ОбновлениеИнформационнойБазы.ЭтотУзел";
		
		Выборка = Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			ПланыОбмена.УдалитьРегистрациюИзменений(Выборка.Узел);
		КонецЦикла;
	КонецЕсли;
	
	ОписанияБиблиотек    = СтандартныеПодсистемыПовтИсп.ОписанияПодсистем().ПоИменам;
	ОбработанныеБиблиотеки = Новый Массив;
	
	ВсегоПроцедур = 0;
	Обработчики = ОбновлениеИнформационнойБазыСлужебный.ОбработчикиДляОтложеннойРегистрацииДанных(Истина);
	Для Каждого Обработчик Из Обработчики Цикл
		Если ОбработанныеБиблиотеки.Найти(Обработчик.ИмяБиблиотеки) <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Если ОписанияБиблиотек[Обработчик.ИмяБиблиотеки].РежимВыполненияОтложенныхОбработчиков <> "Параллельно" Тогда
			ОбновлениеИнформационнойБазыСлужебный.ОтметитьРегистрациюОтложенныхОбработчиковОбновления(Обработчик.ИмяБиблиотеки, Истина);
			ОбработанныеБиблиотеки.Добавить(Обработчик.ИмяБиблиотеки);
			Продолжить;
		КонецЕсли;
		
		ПараллельноСВерсии = ОписанияБиблиотек[Обработчик.ИмяБиблиотеки].ПараллельноеОтложенноеОбновлениеСВерсии;
		
		Если ЗначениеЗаполнено(ПараллельноСВерсии)
			И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(Обработчик.Версия, ПараллельноСВерсии) < 0 Тогда
			Продолжить;
		КонецЕсли;
		
		ОписаниеОбрабатываемыхДанных = ОбновлениеИнформационнойБазыСлужебный.НовоеОписаниеОбрабатываемыхДанных(
			Обработчик.Многопоточный,
			Истина);
		Если Обработчик.Многопоточный Тогда
			ОписаниеОбрабатываемыхДанных.ПараметрыВыборки =
				ОбновлениеИнформационнойБазы.ДополнительныеПараметрыВыборкиДанныхДляМногопоточнойОбработки();
		КонецЕсли;
		
		ОписаниеОбрабатываемыхДанных.ИмяОбработчика = Обработчик.ИмяОбработчика;
		ОписаниеОбрабатываемыхДанных.Очередь = Обработчик.ОчередьОтложеннойОбработки;
		ОписаниеОбрабатываемыхДанных.ПроцедураЗаполнения = Обработчик.ПроцедураЗаполненияДанныхОбновления;
		
		ОписаниеОбрабатываемыхДанных = Новый ХранилищеЗначения(ОписаниеОбрабатываемыхДанных, Новый СжатиеДанных(9));
		ОбновлениеИнформационнойБазыСлужебный.УстановитьСвойствоОбработчика(Обработчик.ИмяОбработчика, "ОбрабатываемыеДанные", ОписаниеОбрабатываемыхДанных);
		
		ВсегоПроцедур = ВсегоПроцедур + 1;
	КонецЦикла;
	
	Если Не ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ()
		И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными") Тогда
		МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
		МодульОбменДаннымиСервер.СброситьЗначениеКонстантыСИзменениямиДляПодчиненногоУзлаРИБСФильтрами();
	КонецЕсли;
	
	ХодРегистрации = Новый Структура;
	ХодРегистрации.Вставить("НачальныйПрогресс", ПрогрессВыполнения);
	ХодРегистрации.Вставить("ВсегоПроцедур", ВсегоПроцедур);
	ХодРегистрации.Вставить("ВыполненоПроцедур", 0);
	
	// Снятие блокировки информационной базы и выполнение регистрации на плане обмена.
	ОбновлениеИнформационнойБазыСлужебный.РазблокироватьИБ(БлокировкаИБ);
	
	Возврат ЗапуститьПроцедурыЗаполненияОтложенныхОбработчиков();
	
КонецФункции

&НаКлиенте
Процедура Подключаемый_ПроверитьПроцедурыЗаполненияОтложенныхОбработчиков()
	
	Результат = ПроверитьПроцедурыЗаполненияОтложенныхОбработчиков();
	
	Если Результат.Статус <> "Выполняется" Тогда
		ЗаполнитьЗначенияСвойств(РезультатВыполненияОбновления, Результат);
		ВыполнитьОбработкуОповещения(ОбработкаЗавершения, РезультатВыполненияОбновления);
		ОтключитьОбработчикОжидания("Подключаемый_ПроверитьПроцедурыЗаполненияОтложенныхОбработчиков");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ЗапуститьПроцедурыЗаполненияОтложенныхОбработчиков()
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Управление многопоточной регистрацией данных отложенного обновления'");
	
	ИмяПроцедуры = "ОбновлениеИнформационнойБазыСлужебный.ЗапускРегистрацииДанныхОтложенногоОбновления";
	РезультатВыполнения = ДлительныеОперации.ВыполнитьВФоне(ИмяПроцедуры, УникальныйИдентификатор, ПараметрыВыполнения);
	
	Возврат ПроверитьПроцедурыЗаполненияОтложенныхОбработчиков(РезультатВыполнения);
	
КонецФункции

&НаСервере
Функция ПроверитьПроцедурыЗаполненияОтложенныхОбработчиков(РезультатВыполненияУправляющегоФЗ = Неопределено)
	
	Если РезультатВыполненияУправляющегоФЗ = Неопределено Тогда
		РезультатВыполненияУправляющегоФЗ = ДлительныеОперации.ОперацияВыполнена(ИдентификаторЗадания);
	КонецЕсли;
	
	Статус = РезультатВыполненияУправляющегоФЗ.Статус;
	
	Если Статус = "Выполнено" Тогда
		ОбновлениеИнформационнойБазыСлужебный.ОтметитьРегистрациюОтложенныхОбработчиковОбновления();
	ИначеЕсли Статус = "Ошибка" Или Статус = "Отменено" Тогда
		Группы = ОбновлениеИнформационнойБазыСлужебный.НовоеОписаниеГруппПотоковРегистрацииДанныхОтложенногоОбновления();
		ОбновлениеИнформационнойБазыСлужебный.ОтменитьВыполнениеВсехПотоков(Группы);
		Возврат РезультатВыполненияУправляющегоФЗ;
	КонецЕсли;
	
	// Обновление прогресса.
	ВыполненоПроцедур = 0;
	Обработчики = ОбновлениеИнформационнойБазыСлужебный.ОбработчикиДляОтложеннойРегистрацииДанных();
	Для Каждого Обработчик Из Обработчики Цикл
		ОписаниеОбрабатываемыхДанных = Обработчик.ОбрабатываемыеДанные.Получить();
		Если ОписаниеОбрабатываемыхДанных.Статус = "Выполнено" Тогда
			ВыполненоПроцедур = ВыполненоПроцедур + 1;
		КонецЕсли;
	КонецЦикла;
	
	ХодРегистрации.ВыполненоПроцедур = ВыполненоПроцедур;
	Если ХодРегистрации.ВсегоПроцедур <> 0 Тогда
		ПрибавкаПрогресса = ХодРегистрации.ВыполненоПроцедур / ХодРегистрации.ВсегоПроцедур * (100 - ХодРегистрации.НачальныйПрогресс);
	Иначе
		ПрибавкаПрогресса = 0;
	КонецЕсли;
	ПрогрессВыполнения = ПрогрессВыполнения + ПрибавкаПрогресса;
	
	Возврат РезультатВыполненияУправляющегоФЗ;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Общие процедуры для всех этапов.

&НаКлиенте
Процедура НачатьЗакрытие() Экспорт
	
	ПодключитьОбработчикОжидания("ПродолжитьЗакрытие", 0.1, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПродолжитьЗакрытие() Экспорт
	
	ВыполняетсяОбновлениеВерсииИБ = Ложь;
	
	ЗакрытьФорму(Ложь, Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура СообщениеОНеудачномОбновлении(ДополнительныеПараметры, ВремяОкончанияОбновления)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбновитьИнформационнуюБазуДействияПриОшибке", ЭтотОбъект);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("КраткоеПредставлениеОшибки",   ДополнительныеПараметры.КраткоеПредставлениеОшибки);
	ПараметрыФормы.Вставить("ПодробноеПредставлениеОшибки", ДополнительныеПараметры.ПодробноеПредставлениеОшибки);
	ПараметрыФормы.Вставить("ВремяНачалаОбновления",      ВремяНачалаОбновления);
	ПараметрыФормы.Вставить("ВремяОкончанияОбновления",   ВремяОкончанияОбновления);
	
	Если ЗначениеЗаполнено(ИмяПланаОбмена) Тогда
		
		МодульОбменДаннымиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбменДаннымиКлиент");
		ИмяОткрываемойФормы = МодульОбменДаннымиКлиент.ИмяФормыСообщенияОНеудачномОбновлении();
		ПараметрыФормы.Вставить("ИмяПланаОбмена", ИмяПланаОбмена);
		
	Иначе	
		ИмяОткрываемойФормы = "Обработка.РезультатыОбновленияПрограммы.Форма.СообщениеОНеудачномОбновлении";
	
	КонецЕсли;
	
	ОткрытьФорму(ИмяОткрываемойФормы, ПараметрыФормы,,,,,ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИнформационнуюБазуДействияПриОшибке(ЗавершитьРаботу, ДополнительныеПараметры) Экспорт
	
	Если БлокировкаИБ <> Неопределено
		И БлокировкаИБ.Свойство("СнятьБлокировкуФайловойБазы") Тогда
		ОбновлениеИнформационнойБазыСлужебныйВызовСервера.СнятьБлокировкуФайловойБазы();
	КонецЕсли;
	
	Если ЗавершитьРаботу <> Ложь Тогда
		ЗакрытьФорму(Истина, Ложь);
	Иначе
		ЗакрытьФорму(Истина, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПерезапускСБлокировкойВыполненияРегламентныхЗаданий()
	
	НовыйПараметрЗапуска = ПараметрЗапуска + ";РегламентныеЗаданияОтключены";
	НовыйПараметрЗапуска = "/AllowExecuteScheduledJobs -Off " + "/C """ + НовыйПараметрЗапуска + """";
	ПрекратитьРаботуСистемы(Истина, НовыйПараметрЗапуска);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УстановитьПараметрыСеансаИзФоновогоЗадания(ПараметрыКлиентаНаСервере)
	
	ПараметрыСеанса.ПараметрыКлиентаНаСервере = ПараметрыКлиентаНаСервере;
	ПараметрыСеанса.ВыполняетсяОбновлениеИБ = Ложь;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ОбработанныйРезультатДлительнойОперации(Результат, Операция)
	
	Возврат РегистрыСведений.ПараметрыРаботыПрограммы.ОбработанныйРезультатДлительнойОперации(Результат, Операция);
	
КонецФункции

#КонецОбласти
