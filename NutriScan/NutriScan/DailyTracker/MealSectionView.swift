import SwiftUI

struct MealSectionView: View {
    let mealType: String
    @Binding var meals: [MealData]
    @Binding var showAddMealView: Bool
    @State private var recognizedText = ""
    @State private var showScanner = false
    @Binding var currentMealType: String
    let userId: String
    @AppStorage("navMealType") var navMealType: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            // Meal type and buttons
            HStack {
                Text(mealType.uppercased())
                    .fontWeight(.bold)

                Spacer()

                Button(action: {
                    currentMealType = mealType
                    showScanner = true
                }) {
                    Image(systemName: "doc.text.viewfinder")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color("ColorGreenAdaptive"))
                }
                .padding(.trailing, 10)

                Button(action: {
                    print("Setting currentMealType to: \(mealType)")
                    currentMealType = mealType
                    navMealType = mealType
                    showAddMealView = true
                }) {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color("ColorGreenAdaptive"))
                }
            }
            .padding(.bottom, 5) // Add some spacing between the buttons and the nutritional info

            // Nutritional elements
            HStack {
                VStack {
                    Text("Calories")
                    Text("\(meals.reduce(0) { $0 + $1.calories }, specifier: "%.2f")")
                }
                Spacer()

                VStack {
                    Text("Proteins")
                    Text("\(meals.reduce(0) { $0 + $1.proteins }, specifier: "%.2f")")
                }
                Spacer()

                VStack {
                    Text("Carbs")
                    Text("\(meals.reduce(0) { $0 + $1.carbs }, specifier: "%.2f")")
                }
                Spacer()

                VStack {
                    Text("Fat")
                    Text("\(meals.reduce(0) { $0 + $1.fats }, specifier: "%.2f")")
                }
            }
            .padding(.bottom, 5) // Add some spacing between the nutritional info and the meal list

            // Display each meal item
            ScrollView {
                            VStack {
                                ForEach(meals, id: \.id) { meal in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(meal.name)
                                                .font(.headline)
                                            // Add more meal details here if needed
                                        }
                                        Spacer()
                                        Button(action: {
                                            if let index = meals.firstIndex(where: { $0.id == meal.id }) {
                                                deleteMeal(at: IndexSet(integer: index))
                                            }
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(Color("ColorAppearanceAdaptive"))
                                    .cornerRadius(12)
                                    .shadow(color: Color("ColorBlackTransparentLight"), radius: 4, x:0, y:0)
                                    
                                }
                            }
                            .padding()
                        }
                    
        }.onAppear {
            print("Meals for \(mealType): \(meals)")
        }
        .sheet(isPresented: $showScanner) {
                    TextScannerView(recognizedText: $recognizedText)
                        .onDisappear {
                            let extractedInfo = extractNutritionalInfo(from: recognizedText.components(separatedBy: "\n"))
                            print("Extracted Info: \(extractedInfo)")

                            // Insert the extracted nutritional information into the database
                            MealDataManager.insertNutritionalData(userId: userId, mealType: currentMealType, mealName: "Chips", nutritionalInfo: extractedInfo) { success in
                                if success {
                                    print("Nutritional data saved successfully")
                                    // Optionally, you can update your UI or fetch the updated data here
                                } else {
                                    print("Failed to save nutritional data")
                                }
                            }
                        }
                }
    }

    private func deleteMeal(at offsets: IndexSet) {
        for index in offsets {
            guard let mealId = meals[index].id else { continue }
            MealDataManager.deleteMealData(userId: userId, mealId: mealId) { success in
                if success {
                    DispatchQueue.main.async {
                        meals.remove(atOffsets: offsets)  // Use remove(atOffsets:) to safely delete multiple items
                    }
                }
            }
        }
    }
}
