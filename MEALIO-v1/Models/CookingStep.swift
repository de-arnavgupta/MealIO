import Foundation

public struct CookingStep: Identifiable, Hashable, Codable {
    public var id: UUID
    public var stepIndex: Int
    public var title: String
    public var durationMinutes: Int
    public var instruction: String
    public var hasTimer: Bool
    public var timerDurationSeconds: Int
    public var timerSideLabel: String
    public var petitChefTip: String?
    
    public init(
        id: UUID = UUID(),
        stepIndex: Int,
        title: String,
        durationMinutes: Int,
        instruction: String,
        hasTimer: Bool = false,
        timerDurationSeconds: Int = 90,
        timerSideLabel: String = "FIRST SIDE",
        petitChefTip: String? = nil
    ) {
        self.id = id
        self.stepIndex = stepIndex
        self.title = title
        self.durationMinutes = durationMinutes
        self.instruction = instruction
        self.hasTimer = hasTimer
        self.timerDurationSeconds = timerDurationSeconds
        self.timerSideLabel = timerSideLabel
        self.petitChefTip = petitChefTip
    }
    
    enum CodingKeys: String, CodingKey {
        case id, stepIndex, title, durationMinutes, instruction, hasTimer, timerDurationSeconds, timerSideLabel, petitChefTip
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let uuidStr = try? container.decode(String.self, forKey: .id), let u = UUID(uuidString: uuidStr) {
            self.id = u
        } else {
            self.id = UUID()
        }
        self.stepIndex = (try? container.decodeIfPresent(Int.self, forKey: .stepIndex)) ?? 1
        self.title = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? ""
        self.durationMinutes = (try? container.decodeIfPresent(Int.self, forKey: .durationMinutes)) ?? 5
        self.instruction = (try? container.decodeIfPresent(String.self, forKey: .instruction)) ?? ""
        self.hasTimer = (try? container.decodeIfPresent(Bool.self, forKey: .hasTimer)) ?? false
        self.timerDurationSeconds = (try? container.decodeIfPresent(Int.self, forKey: .timerDurationSeconds)) ?? 0
        self.timerSideLabel = (try? container.decodeIfPresent(String.self, forKey: .timerSideLabel)) ?? "TIMER"
        self.petitChefTip = try? container.decodeIfPresent(String.self, forKey: .petitChefTip)
    }
}
