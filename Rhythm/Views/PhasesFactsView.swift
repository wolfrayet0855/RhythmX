//
//  PhasesFactsView.swift
//  Rhythm
//
//  Created by user on 1/3/25.
//

import SwiftUI

/// A simple container for the entire text of one phase block.
struct PhaseTextBlock: Identifiable {
    let id = UUID()
    let content: String
}

struct PhasesFactsView: View {
    
    /// All 4 phases, stored as complete multiline text blocks.
    /// Each block here is exactly what you wrote, including headings and spacing.
    private let phases: [PhaseTextBlock] = [
        PhaseTextBlock(content: """
1. Menstrual Phase

Approximate Timing: Day 1 to Day 5
(Overlaps with the early part of the follicular phase)

What’s Happening Biologically
Hormones: Levels of estrogen and progesterone are relatively low at the start of menstruation because the corpus luteum (leftover from the previous cycle) is no longer producing high levels of progesterone.
Uterine Lining: The endometrium (uterine lining) sheds, leading to menstrual bleeding.

Pregnancy Probability
Very Low: Since menstruation generally marks the beginning of a new cycle and ovulation is still roughly 10–14 days away, the probability of becoming pregnant is minimal during this time. However, it is not absolutely zero—especially if someone has a shorter cycle or if sperm remains viable in the reproductive tract for several days.

Common Mood & Symptoms
Mood: Some individuals may experience relief from premenstrual syndrome (PMS) symptoms once bleeding begins, while others might still feel mood fluctuations (cramps, fatigue, irritability).
Physical Symptoms: Cramping (dysmenorrhea), bloating, backaches, breast tenderness, and headaches. Energy levels may be lower.

Tips/Benefits:
Warm compresses or gentle heat can help relieve cramps.
Staying hydrated and keeping up light, moderate exercise (such as yoga, walking) can improve mood and circulation.
Iron-rich foods or supplements may help if you’re prone to low iron due to menstrual blood loss (consult with a healthcare provider for personalized advice).
"""),
        PhaseTextBlock(content: """
2. Follicular Phase

Approximate Timing: Day 1 to Day 13
(Begins on Day 1, overlaps with menstruation until bleeding stops; continues up to ovulation)

What’s Happening Biologically
Hormones: Follicle-stimulating hormone (FSH) from the pituitary gland stimulates ovarian follicles to develop. Estrogen levels begin to rise.
Ovarian Follicles: Several follicles start to mature, but usually only one becomes dominant and is prepared for ovulation.
Uterine Lining: The endometrium starts to thicken again under rising estrogen levels.

Pregnancy Probability
Increasing but Still Moderate: The closer you get to ovulation (toward the end of the follicular phase), the higher the chance of pregnancy if unprotected intercourse occurs. Sperm can survive up to about five days in fertile cervical mucus.

Common Mood & Symptoms
Mood: As estrogen climbs, many people notice improved mood, higher energy, clearer thinking, and an overall sense of well-being.
Physical Symptoms: A possible gradual boost in libido, more cervical fluid that is thinner and more elastic (“fertile mucus”), and potentially fewer PMS-like symptoms compared to the luteal phase.

Tips/Benefits:
This is often a good time for high-energy workouts and social activities.
If trying to conceive, tracking cervical mucus changes or using ovulation predictor kits can be helpful toward the end of the follicular phase.
"""),
        PhaseTextBlock(content: """
3. Ovulatory Phase

Approximate Timing: Around Day 14 (in a 28-day cycle)

What’s Happening Biologically
Hormones: A surge in luteinizing hormone (LH) triggers the dominant follicle in the ovary to release the mature egg (ovum).
Ovulation: The egg is released into the fallopian tube, where it remains viable for about 12–24 hours.

Pregnancy Probability
Peak Fertility Window: This is the highest probability time for conception. Sperm present in the reproductive tract around ovulation (up to five days prior, day of, or shortly after) can fertilize the egg.

Common Mood & Symptoms
Mood: Often an uptick in libido, energy, and confidence due to peaking estrogen and testosterone levels.
Physical Symptoms: Some individuals experience mild pelvic twinges (Mittelschmerz), increased cervical mucus (clear, stretchy, “egg white” consistency), possibly a slight increase in basal body temperature after ovulation.

Tips/Benefits:
If trying to conceive, having intercourse in the days leading up to and including ovulation is key.
Staying hydrated and listening to your body can help manage any mild ovulatory discomfort.
"""),
        PhaseTextBlock(content: """
4. Luteal Phase

Approximate Timing: Day 15 to Day 28

What’s Happening Biologically
Hormones: After the egg is released, the follicle transforms into the corpus luteum, which secretes progesterone (and some estrogen). Progesterone prepares the uterus for a possible pregnancy.
Uterine Lining: The endometrium becomes more glandular and thicker to potentially support an embryo.

Pregnancy Probability
Higher Early in the Luteal Phase, Then Decreases:
If fertilization and implantation occur, progesterone remains high (supported by human chorionic gonadotropin, or hCG) to sustain pregnancy.
If no implantation occurs, progesterone production drops, leading to the shedding of the uterine lining (menstruation).

Common Mood & Symptoms
Mood: Potential for PMS/PMDD symptoms due to falling progesterone and estrogen toward the end of the luteal phase if pregnancy does not occur. Symptoms may include irritability, low mood, anxiety, mood swings.
Physical Symptoms: Bloating, breast tenderness, fatigue, food cravings, changes in bowel habits, possible fluid retention.

Tips/Benefits:
Focus on nutrient-dense foods, balanced meals, and adequate hydration to stabilize mood and energy.
Moderate exercise, mindfulness, and stress-reduction techniques can alleviate PMS symptoms.
Tracking symptoms can help identify patterns and better manage the physical and emotional fluctuations.
""")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // For each block of text, we parse it by lines
                    ForEach(phases) { block in
                        VStack(alignment: .leading, spacing: 6) {
                            let lines = block.content.components(separatedBy: .newlines)
                            
                            ForEach(lines.indices, id: \.self) { i in
                                let line = lines[i]
                                if line.isEmpty {
                                    // Empty line => add a small spacer for extra vertical space
                                    Spacer().frame(height: 8)
                                } else {
                                    // Show text, bolding anything before the first colon
                                    boldTextBeforeColon(line)
                                }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    // Fun, lighthearted disclaimer at the bottom
                    Spacer().frame(height: 24)
                    Text("""
Disclaimer: The information above is for your general knowledge and educational purposes – not a substitute for professional medical advice! Always consult a doctor if you have any health concerns. Keep grooving, stay informed, and remember: your body is unique, and we're just here to help you find your rhythm.
""")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Menstrual Phases")
        }
    }
    
    /// A helper that returns a Text view with everything before the first colon (if any) in bold.
    @ViewBuilder
    private func boldTextBeforeColon(_ line: String) -> some View {
        if let colonIndex = line.firstIndex(of: ":") {
            let keyPart = line[..<colonIndex]    // e.g. "Hormones"
            let valPart = line[line.index(after: colonIndex)...] // e.g. " Levels of..."
            
            // Construct a single Text with the first portion in bold
            Text(.init("**\(keyPart):**\(valPart)"))
                .font(.body)
        } else {
            // No colon => just show normally
            Text(line)
                .font(.body)
        }
    }
}

struct PhasesFactsView_Previews: PreviewProvider {
    static var previews: some View {
        PhasesFactsView()
    }
}
