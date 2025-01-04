import SwiftUI
import StoreKit

struct ContentView : View {
    @State var isPresented : Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Click the “Show Store” button below and visit both tabs in the sheet that appears. See how the sheet adjusts its size to accommodate the two different views. On the ”Purchases” tab, click one of the buy buttons on a product, then click “Cancel” on the dialog that appears to cancel the purchase. Seems like nothing happened, right? Well, go take a look at what has happened to the layout of ”Subscrption” tab! Then go back the the ”Purchases” tab and see how its layout is also wacky now. Then try switching back to the ”Subscrption” tab. This has all got to be a bug, right?")

            Button(action: {
                isPresented = true
            }) {
                Text("Show Store")
                    .font(.system(size: 18))
                    .padding(5)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $isPresented) {
            StoreSheetView()
                .frame(width: 360)
        }
    }
}

struct StoreSheetView: View {
    @State private var products : [Product] = []
    @State private var isLoadingProducts = true
    @State private var productLoadingError : Error? = nil

    let productIds = [
        "com.example.product.one",
        "com.example.product.two",
        "com.example.product.three",
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView {
                VStack(alignment: .leading) {
                    if isLoadingProducts {
                        if let error = productLoadingError {
                            Text("Failed to load products due to an error.\n\nError: \(error)")
                        }
                        else {
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())

                                Text("Loading products")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .center)
                        }
                    }
                    else {
                        ForEach(products, id: \.id) { product in
                            ProductView(product, prefersPromotionalIcon: false)
                                .productViewStyle(.compact)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
                .border(.green)
                .tabItem {
                    Text("Purchases")
                }
                .tag(0)

                SubscriptionStoreView(groupID: "8C0A76E7", visibleRelationships: .all)
                    .storeButton(.hidden, for: .cancellation)
                    .storeButton(.hidden, for: .restorePurchases)
                    .backgroundStyle(.clear)
                    .subscriptionStoreButtonLabel(.multiline)
                    .subscriptionStoreControlStyle(.compactPicker)
                    .padding()
                    .border(.red)
                    .tabItem {
                        Text("Subscriptions")
                    }
                    .tag(1)
            }

            HStack {
                Text("Privacy")
                Text("•")
                Text("Terms")
            }
            .padding()
        }
        .padding()
        .task {
            do {
                products = try await Product.products(for: productIds)
                products.sort(by: { $0.price < $1.price })
                isLoadingProducts = false
            }
            catch {
                productLoadingError = error
            }
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 500, height: 500)
}

#Preview("Store") {
    StoreSheetView()
        .frame(width: 360, height: 470)
}
