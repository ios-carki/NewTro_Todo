import Foundation

/// 통계 탭 "최근 7일" 막대 한 칸에 들어갈 완료/미완료 수.
struct WeeklyDayCounts: Equatable {
    let completed: Int
    let incomplete: Int

    var total: Int { completed + incomplete }
    var isEmpty: Bool { total == 0 }
}
