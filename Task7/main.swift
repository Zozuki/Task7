//
//  main.swift
//  Task7
//
//  Created by user on 30.03.2021.
//

import Foundation

struct Product {
    var name: String
}

struct Drink {
    var price: Int
    var liters: Int
    let product: Product
}

// Возможные ошибки при покупке
enum BarErrors: Error {
    
    case invalidSelection(drinkName: String)
    case outOfStock(drinkName: String)
    case insufficientFunds(coinsNeeded: Int, drinkName: String)
    
    var localizedDescription: String {
        switch self {
        case .invalidSelection(drinkName: let drinkName):
            return "\(drinkName) - нет в ассортименте"
        case .outOfStock(drinkName: let drinkName):
            return "\(drinkName) - нет в наличии"
        case .insufficientFunds(coinsNeeded: let coinsNeeded, drinkName: let drinkName):
            return "Недостаточно денег: \(coinsNeeded) на покупку \(drinkName)"
        }
    }
}

//1. Придумать класс, методы которого могут завершаться неудачей и возвращать либо значение, либо ошибку Error?.
class Bar {
    
    var assortment = [
        "Beer": Drink(price: 5, liters: 15, product: Product(name: "Beer")),
        "Mojito": Drink(price: 10, liters: 5, product: Product(name: "Mojito")),
        "Absinthe": Drink(price: 25, liters: 0, product: Product(name: "Absinthe"))
    ]
    
    var moneyDeposite = 0
    
    func buy(drinkName name: String) -> (product: Product?, error: BarErrors?) {
        
        guard let drink = assortment[name] else {
            return (product: nil, error: BarErrors.invalidSelection(drinkName: name))
        }
        
        guard drink.liters > 0 else {
            return (product: nil, error: BarErrors.outOfStock(drinkName: name))
        }
        
        guard moneyDeposite >= drink.price else {
            return (product: nil, error: BarErrors.insufficientFunds(coinsNeeded: drink.price - moneyDeposite, drinkName: name))
        }
       
        moneyDeposite -= drink.price
        
        var newItem = drink
        newItem.liters -= 1
        
        assortment[name] = newItem
        return (product: drink.product, error: nil)
    }
    
}


let bar = Bar()
bar.moneyDeposite = 5
let sell1 = bar.buy(drinkName: "Beer")
let sell2 = bar.buy(drinkName: "Vodka")
let sell3 = bar.buy(drinkName: "Absinthe")

// Реализовать вызов методов с возможной ошибкой и обработать результат метода при помощи конструкции if let, или guard let.
if let drink = sell1.product {
    print("Мы купили: \(drink.name)") // Мы купили: Beer
} else if let error = sell1.error {
    print("Ошибка: \(error.localizedDescription)")
}

if let drink = sell2.product {
    print("Мы купили: \(drink.name)")
} else if let error = sell2.error {
    print("Ошибка: \(error.localizedDescription)") // Ошибка: Vodka - нет в ассортименте
}

if let drink = sell3.product {
    print("Мы купили: \(drink.name)")
} else if let error = sell3.error {
    print("Ошибка: \(error.localizedDescription)") // Ошибка: Absinthe - нет в наличии
}



//2. Придумать класс, методы которого могут выбрасывать ошибки.
class BarThrow {
    
    var assortment = [
        "Beer": Drink(price: 5, liters: 15, product: Product(name: "Beer")),
        "Mojito": Drink(price: 10, liters: 5, product: Product(name: "Mojito")),
        "Absinthe": Drink(price: 25, liters: 0, product: Product(name: "Absinthe"))
    ]
    
    var moneyDeposite = 0
    
//Реализуйте несколько throws-функций.
    func buy(drinkName name: String) throws -> Product {
        
        guard let drink = assortment[name] else {
            throw BarErrors.invalidSelection(drinkName: name)
        }
       
        guard drink.liters > 0 else {
            throw BarErrors.outOfStock(drinkName: name)
        }
        
        guard moneyDeposite >= drink.price else {
            throw BarErrors.insufficientFunds(coinsNeeded: drink.price - moneyDeposite, drinkName: name)
        }
        moneyDeposite -= drink.price
        
        var newItem = drink
        newItem.liters -= 1
        
        assortment[name] = newItem
        return drink.product
    }
    
}

//Вызовите throws-функции и обработайте результат вызова при помощи конструкции try/catch.
let newBar = BarThrow()

do {
    let someSell = try newBar.buy(drinkName: "Absinthe")
    print("Мы купили: \(someSell.name)")
} catch let error {
    print(error) // outOfStock(drinkName: "Absinthe")
}

do {
    let someSell = try newBar.buy(drinkName: "Beer")
    print("Мы купили: \(someSell.name)")
} catch let error {
    print(error) // insufficientFunds(coinsNeeded: 5, drinkName: "Beer")
}

do {
    let someSell = try newBar.buy(drinkName: "Vodka")
    print("Мы купили: \(someSell.name)")
} catch let error {
    print(error) // invalidSelection(drinkName: "Vodka")
}
newBar.moneyDeposite = 10

do {
    let someSell = try newBar.buy(drinkName: "Mojito") // Мы купили: Mojito
    print("Мы купили: \(someSell.name)")
} catch let error {
    print(error)
}

// Также еще решил попробовать вот такой вариант реализации, чтобы мы могли прочитать свойство "localizedDescription" и при этом убрать его опциональность
do {
    let someSell = try newBar.buy(drinkName: "Beer") // едостаточно денег: 5 на покупку Beer
    print("Мы купили: \(someSell.name)")
} catch let error {
    guard let errorDep = error as? BarErrors else {
        print(error)
        throw error
    }
    print(errorDep.localizedDescription)
}
