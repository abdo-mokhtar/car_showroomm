import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/owner.dart';
import '../../repositories/owners_repository.dart';
import 'owners_state.dart';

class OwnersCubit extends Cubit<OwnersState> {
  final OwnersRepository _ownersRepository;

  OwnersCubit(this._ownersRepository) : super(const OwnersInitial());

  // ✅ تحميل كل المالكين
  Future<void> loadAllOwners() async {
    emit(const OwnersLoading());
    try {
      final owners = await _ownersRepository.getAllOwners();
      emit(OwnersLoaded(owners: owners));
    } catch (e) {
      emit(OwnersError(e.toString()));
    }
  }

  // ✅ بحث عن مالك
  Future<void> searchOwners(String query) async {
    emit(const OwnersLoading());
    try {
      final owners = await _ownersRepository.searchOwners(query);
      emit(OwnersLoaded(owners: owners));
    } catch (e) {
      emit(OwnersError(e.toString()));
    }
  }

  // ✅ إضافة مالك
  Future<void> insertOwner(Owner owner) async {
    try {
      await _ownersRepository.insertOwner(owner);
      emit(const OwnersOperationSuccess('تم إضافة المالك بنجاح'));
      await loadAllOwners();
    } catch (e) {
      emit(OwnersError(e.toString()));
    }
  }

  // ✅ تعديل مالك
  Future<void> updateOwner(Owner owner) async {
    try {
      await _ownersRepository.updateOwner(owner);
      emit(const OwnersOperationSuccess('تم تعديل المالك بنجاح'));
      await loadAllOwners();
    } catch (e) {
      emit(OwnersError(e.toString()));
    }
  }

  // ✅ حذف مالك
  Future<void> deleteOwner(int id) async {
    try {
      await _ownersRepository.deleteOwner(id);
      emit(const OwnersOperationSuccess('تم حذف المالك بنجاح'));
      await loadAllOwners();
    } catch (e) {
      emit(OwnersError(e.toString()));
    }
  }
}
