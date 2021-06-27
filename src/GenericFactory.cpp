//
// Created by Diego Urgell on 15/06/21.
//

#include <memory>
#include <map>
#include <string>

/**
 * GenericFactory for the different types of implementations of an interface T. Polymorphism is used so that every subclass
 * can be handled with class T pointers. The different types are stored in a map of string -> creation Method. Evey subtype
 * of the class is self-registered by using a static member that calls the is_registered method.
 * @tparam T represents the interface which every subtype to be registered in the factory implements.
 */
template<class T>
class GenericFactory {
public:

    using objectCreateMethod = std::shared_ptr<T>(*)(); // Pointer to a function that returns a shared pointer of class T
    inline static std::map<std::string, objectCreateMethod> regSpecs = std::map<std::string, objectCreateMethod>();

public:

    GenericFactory<T>() = default;

    /**
     * Method to register a subclass into the factory by providing the factoryName string and the objectCreate method,
     * which must be implemented by the specific subclass of the interface.
     * @param name string to register the subclass
     * @param funcCreate function to create an object of the subclass
     * @return A boolean indicating if registration was successful
     */
    static bool Register(const std::string name, objectCreateMethod funcCreate) {
        if (auto it = regSpecs.find(name); it == regSpecs.end()) {
            regSpecs[name] = funcCreate;
            return true;
        }
        return false;
    }

    /**
     * The create method receives a factoryName string, retrieves the createMethod from the regSpecs map and instantiates
     * the specific subclass, returning a pointer of type T (interface).
     * @param name factoryName of the subclass.
     * @return A shared pointer of the interface class' type, or nullptr if the name is not registered.
     */
    static std::shared_ptr<T> Create(const std::string name) {
        if (auto it = regSpecs.find(name); it != regSpecs.end()) return (it->second)(); // Call the function
        return nullptr;
    }
};


/**
 * Ths class helps to automatically register a class in its interface factory by using its factoryName. It is only
 * necessary to instantiate this template class with the correct template parameters.
 * @tparam S The specialization (i.e. BinarySegmentation)
 * @tparam I The interface (i.e Algorithm)
 * @tparam F The factory (i.e. AlgorithmFactory)
 */
template<class S, class I, class F>
class Registration {
public:
    Registration() = default;

    /**
     * This is the object creation method that is called from the factory whenever a new object of a specific interface
     * is instantiated. It creates a shared pointer of type of the Specialization class, but returns it as shared pointer
     * of the interface class, enabling polymorphism.
     * @return a shared pointer of the interface class, pointing to an object of a subclass.
     */
    static std::shared_ptr<I> createMethod() {
        return std::make_shared<S>();
    }

protected:
    inline static bool is_registered = F::Register(S::factoryName, S::createMethod);
};
