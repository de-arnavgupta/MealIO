import Foundation

public struct Ingredient: Identifiable, Hashable, Codable {
    public var id: UUID
    public var name: String
    public var note: String?
    public var baseQuantity: Double?
    public var unit: String
    public var displayOverride: String?
    public var isInPantry: Bool
    public var isSelectedForGrocery: Bool
    public var aisleCategory: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        note: String? = nil,
        baseQuantity: Double? = nil,
        unit: String = "",
        displayOverride: String? = nil,
        isInPantry: Bool = false,
        isSelectedForGrocery: Bool = true,
        aisleCategory: String = "Pantry"
    ) {
        self.id = id
        self.name = name
        self.note = note
        self.baseQuantity = baseQuantity
        self.unit = unit
        self.displayOverride = displayOverride
        self.isInPantry = isInPantry
        self.isSelectedForGrocery = isSelectedForGrocery
        self.aisleCategory = aisleCategory
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, note, baseQuantity, unit, displayOverride, isInPantry, isSelectedForGrocery, aisleCategory
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let uuidStr = try? container.decode(String.self, forKey: .id), let u = UUID(uuidString: uuidStr) {
            self.id = u
        } else {
            self.id = UUID()
        }
        self.name = try container.decode(String.self, forKey: .name)
        self.note = try? container.decodeIfPresent(String.self, forKey: .note)
        self.baseQuantity = try? container.decodeIfPresent(Double.self, forKey: .baseQuantity)
        self.unit = (try? container.decodeIfPresent(String.self, forKey: .unit)) ?? ""
        self.displayOverride = try? container.decodeIfPresent(String.self, forKey: .displayOverride)
        self.isInPantry = (try? container.decodeIfPresent(Bool.self, forKey: .isInPantry)) ?? false
        self.isSelectedForGrocery = (try? container.decodeIfPresent(Bool.self, forKey: .isSelectedForGrocery)) ?? true
        self.aisleCategory = (try? container.decodeIfPresent(String.self, forKey: .aisleCategory)) ?? "Pantry"
    }
    
    public func formattedQuantity(forServings servings: Int, baseServings: Int = 2) -> String {
        if let displayOverride = displayOverride {
            return displayOverride
        }
        guard let base = baseQuantity else { return "" }
        let factor = Double(servings) / Double(max(baseServings, 1))
        let scaled = base * factor
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.minimumFractionDigits = 0
        let formattedNumber = numberFormatter.string(from: NSNumber(value: scaled)) ?? "\(scaled)"
        
        if unit.isEmpty {
            return formattedNumber
        } else {
            return "\(formattedNumber) \(unit)"
        }
    }
}
